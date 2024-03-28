from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from models.user import UserInDB, Token
from database.db import users_collection
from controllers.auth_functions import create_access_token, authenticate_user, get_current_user, get_hashed_password, ACCESS_TOKEN_EXPIRE_MINUTES
from datetime import timedelta

router = APIRouter()

# request to register new user

@router.post("/create-user")
async def create_user(email : str, form_data: OAuth2PasswordRequestForm = Depends() ):
    user = authenticate_user(form_data.username, form_data.password)

    if user:
        raise HTTPException(status_code=400, detail= "User already exists")
    
    hashed_password = get_hashed_password(form_data.password)

    new_user = UserInDB(username=form_data.username, email= email, hashed_password= hashed_password)
    new_user = dict(new_user)

    res = users_collection.insert_one(new_user)

    if res.inserted_id:
        return {"message": f"User {res.inserted_id} created successfully"}
    else:
        raise HTTPException(status_code=500, detail="Failed to create user")
    

# request to log in an existing user
@router.post("/token", response_model=Token)
async def login_user(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)

    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")
    user = users_collection.find_one({"username" : form_data.username})
    access_token_expires = timedelta(minutes= ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(user_data={"sub": str(user["_id"])}, expires_delta=access_token_expires)
    return {"access_token": access_token, "token_type": "bearer"}
