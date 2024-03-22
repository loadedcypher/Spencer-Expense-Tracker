from fastapi import APIRouter, HTTPException
from database.db import users_collection
from models.user import User
from pydantic import BaseModel


router = APIRouter()

@router.post('/add_user')
def add_user(user: User):
    user_data = {
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email
    }


    res = users_collection.insert_one(user_data)

    if res.inserted_id:
        return BaseModel.model_json_schema
    else:
        raise HTTPException(status_code=500, detail="Failed to create user")