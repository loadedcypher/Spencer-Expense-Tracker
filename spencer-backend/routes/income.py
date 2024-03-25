from fastapi import APIRouter, Depends, HTTPException, status
from models.user import UserInDB
from database.db import income_collection
from controllers.auth_functions import get_current_user
from models.income import Income
from models.user import UserInDB


router = APIRouter()


# add income

@router.post('/add-income')
async def add_income(income: Income, current_user: UserInDB = Depends(get_current_user)):
    income_data = dict(income)
    income_data['user_id'] = current_user['_id']
    res = income_collection.insert_one(income_data)

    if res.inserted_id:
        return {"message": f"Income added {res.inserted_id} created successfully for {current_user['username']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to add income")
    