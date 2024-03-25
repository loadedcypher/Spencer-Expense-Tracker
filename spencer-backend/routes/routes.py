from fastapi import APIRouter, HTTPException
from database.db import users_collection
from models.user import User
from pydantic import BaseModel


router = APIRouter()

# add a user to the databse after signing in.

@router.post('/add_user')
def add_user(user: User):
    income_sources = []
    expenses = []
    if user.income_sources:
        income_sources = [income.to_dict() for income in user.income_sources]
    
    if user.expenses_logs:
        expenses = [expense.to_dict() for expense in user.expenses_logs]

    user_data = dict(user)
    user_data['income_sources'] = income_sources
    user_data['expenses_logs'] = expenses
    user_data['total_monthly_income'] = user.total_monthly_income
    res = users_collection.insert_one(user_data)
    if res.inserted_id:
        return {"message": "User created successfully"}
    else:
        raise HTTPException(status_code=500, detail="Failed to create user")


# user enter their remaining data(income sources, total montly income...etc)

# 

