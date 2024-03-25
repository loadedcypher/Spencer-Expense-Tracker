# AUTHORIZATION AND AUTHENTICATION FUNCTIONS

from passlib.context import CryptContext
from database.db import users_collection
from models.user import UserInDB
from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from bson.objectid import ObjectId

# Secret Key for hashing

SECRET_KEY = "2fba26191e3fbb7716ad59ee1c6bcda21d65e3c1718717f9b3a7621fd574afce"

# The algorithm that will be used for hashing.

HASHING_ALGORITHM = "HS256"

# life-span of validity of the token 

ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Password hashing function

pwd_context = CryptContext(schemes=["bcrypt"], deprecated = "auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# to check if the password matches the hashed password.

def verify_password(plain_password: str, hashed_password: str)->bool:
    return pwd_context.verify(plain_password, hashed_password)

# a function to hash the password.

def get_hashed_password(password: str)->str:
    return pwd_context.hash(password)

# a function to check if the user exists in the database.

def authenticate_user(username: str, password: str):
    user = users_collection.find_one({"username" : username})

    if not user or not verify_password(password, user["hashed_password"]):
        return None
    
    return UserInDB(**user)

# a function to create an access token

def create_access_token(user_data: dict, expires_delta: timedelta = None):
    to_encode = user_data.copy()

    if expires_delta:
        expire = datetime.now() + expires_delta
    else:
        expire = datetime.now() + timedelta(minutes=15)

    to_encode.update({"exp": expire})
    encoded_jwt =  jwt.encode(to_encode, SECRET_KEY, algorithm=HASHING_ALGORITHM)
    return encoded_jwt

# get the user that is currently logged in.

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = await jwt.decode(token, SECRET_KEY, algorithms=[HASHING_ALGORITHM])
        user_id = await payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    
    user = await users_collection.find_one({"_id": ObjectId(users_collection)})

    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user

if __name__ == "__main__":
    pass