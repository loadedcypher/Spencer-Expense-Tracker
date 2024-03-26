from fastapi import APIRouter, Depends, HTTPException, status
from models.user import UserInDB
from database.db import budget_collection
from controllers.auth_functions import get_current_user
from models.income import Budget
from models.user import UserInDB
from bson.objectid import ObjectId

router = APIRouter()

@router.post("/add_budget")
def add_budget(budget: Budget, current_user: UserInDB = Depends(get_current_user)):
    budget_data = dict(budget)
    budget_data['user_id'] = current_user['_id']
    res = budget_collection.insert_one(budget_data)

    if res.inserted_id:
        return {"message": f"Budget added {res.inserted_id} created successfully for {current_user['username']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to add Budget")

@router.get("/get_all_budgets")
def get_budget( current_user: UserInDB = Depends(get_current_user)):
    budgets = budget_collection.find({"user_id": ObjectId(current_user['_id'])}, {'_id': 0, 'user_id':0})
    if not budgets:
        raise HTTPException(status_code=404, detail="Budget not found")
    return budgets


@router.get("/budgets/{category}")
def get_budget(category: str, current_user: UserInDB = Depends(get_current_user)):
    budget = budget_collection.find_one({"category": category, "user_id": ObjectId(current_user['_id'])}, {'_id': 0, 'user_id':0})
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    return budget