from fastapi import APIRouter, Depends, HTTPException
from database.db import income_collection
from controllers.auth_functions import get_current_user
from models.income import Income, IncomeRequest
from models.user import UserInDB
from bson.objectid import ObjectId
from datetime import datetime

router = APIRouter()

# Add income source
@router.post('/add-income')
async def add_income(income: IncomeRequest, current_user: UserInDB = Depends(get_current_user)):
    income_data = dict(income)
    
    income_data = Income(user_id=current_user['_id'],source=income_data['source'], amount=income_data['amount'], date_received= datetime.now())

    res = income_collection.insert_one(dict(income_data))

    if res.inserted_id:
        return {"message": f"Income added {res.inserted_id} created successfully for {current_user['username']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to add income")

# Get all of the user's income sources
@router.get("/get_all_income_sources")
async def get_all_income_sources(current_user: UserInDB = Depends(get_current_user)):
    sources = [income for income in income_collection.find({"user_id": ObjectId(current_user['_id'])}, {'_id': 0, 'user_id':0})]
    return sources

# Get the total income for that month
@router.get("/total-income")
async def get_total_income(current_user: UserInDB = Depends(get_current_user)):
    total_income = sum(income['amount'] for income in income_collection.find({"user_id": ObjectId(current_user['_id'])}))
    return {"total_income": total_income}

# Update income source
@router.put("/update-income/{source}")
async def update_income(source: str, income: Income, current_user: UserInDB = Depends(get_current_user)):
    updated_income = income_collection.update_one(
        {"source": source, "user_id": current_user['_id']},
        {"$set": dict(income)}
    )
    if updated_income.modified_count == 1:
        return {"message": f"Income source updated successfully"}
    else:
        raise HTTPException(status_code=404, detail="Income source not found")

# Delete income source
@router.delete("/delete-income/{source}")
async def delete_income(source: str, current_user: UserInDB = Depends(get_current_user)):
    deleted_income = income_collection.delete_one({"source": source, "user_id": current_user['_id']})
    if deleted_income.deleted_count == 1:
        return {"message": f"Income source deleted successfully"}
    else:
        raise HTTPException(status_code=404, detail="Income source not found")
