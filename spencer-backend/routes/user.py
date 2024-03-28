from fastapi import APIRouter, Depends, HTTPException
from models.user import UserInDB
from database.db import users_collection
from controllers.auth_functions import get_current_user
from models.expense import Expense
from models.user import UserInDB
from bson.objectid import ObjectId

router = APIRouter()

@router.get("/get_user_details")
def show_user_details( current_user: UserInDB = Depends(get_current_user)):
    current_user = dict(current_user)
    current_user.update({"_id": str(current_user["_id"])})
    if not current_user:
        raise HTTPException(status_code=400, detail=f"User Details not Found")
    
    return current_user


