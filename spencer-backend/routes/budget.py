from fastapi import APIRouter, Depends, HTTPException, status
from models.user import UserInDB
from database.db import budget_collection
from controllers.auth_functions import get_current_user
from models.income import Budget
from models.user import UserInDB

router = APIRouter()

@router.post("/budgets")
def add_budget(budget: Budget, current_user: UserInDB = Depends(get_current_user)):
    budget_collection.budgets.insert_one(budget.dict())
    return {"message": "Budget added successfully"}


@router.get("/budgets/{category}")
def get_budget(category: str, current_user: UserInDB = Depends(get_current_user)):
    budget = budget_collection.find_one({"category": category})
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    return budget