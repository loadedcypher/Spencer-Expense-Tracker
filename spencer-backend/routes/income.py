from fastapi import APIRouter, Depends, HTTPException
from database.db import income_collection
from controllers.auth_functions import get_current_user
from models.income import Income
from models.user import UserInDB
from bson.objectid import ObjectId


router = APIRouter()


# add income source
@router.post('/add-income')
async def add_income(income: Income, current_user: UserInDB = Depends(get_current_user)):
    income_data = dict(income)
    income_data['user_id'] = current_user['_id']
    res = income_collection.insert_one(income_data)

    if res.inserted_id:
        return {"message": f"Income added {res.inserted_id} created successfully for {current_user['username']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to add income")

# get all of the user's income sources
@router.get("/get_all_income_sources")
async def get_all_income_sources(current_user: UserInDB = Depends(get_current_user)):
    sources = [income for income in income_collection.find({"user_id": ObjectId(current_user['_id'])}, {'_id': 0, 'user_id':0})]
    return sources

# get the total income for that month
@router.get("/total-income")
async def get_total_income(current_user: UserInDB = Depends(get_current_user)):
    total_income = sum(income['amount'] for income in income_collection.find({"user_id": ObjectId(current_user['_id'])}))
    return {"total_income": total_income}
    