from fastapi import APIRouter, Depends, HTTPException
from models.user import UserInDB
from database.db import budget_collection, expense_collection
from controllers.auth_functions import get_current_user
from models.expense import Expense, ExpenseRequest
from models.user import UserInDB
from bson.objectid import ObjectId
from datetime import datetime

router = APIRouter()

@router.post("/add-expense")
def add_expense(expense: ExpenseRequest, current_user: UserInDB = Depends(get_current_user)):
    expense_data = dict(expense)
    expense_data = Expense(user_id=current_user["_id"], title=expense_data['title'], description=expense_data['description'], amount_spent=expense_data["amount_spent"], expense_category=expense_data["expense_category"], date_spent= datetime.now())
    expense_data = dict(expense)

    # Check if budget exists for the expense category
    budget = budget_collection.find_one({"category": expense_data['expense_category'], "user_id": ObjectId(current_user['_id'])})
    if not budget:
        raise HTTPException(status_code=400, detail=f"No budget found for category {expense_data['expense_category']}")

    # Check if expense amount exceeds budget
    if expense_data['amount_spent'] > budget['amount']:
        raise HTTPException(status_code=400, detail=f"Expense amount exceeds budget for category {expense_data['expense_category']}")

    expense_collection.insert_one(expense_data)
    

    # Update remaining budget
    remaining_budget = budget['amount'] - expense_data['amount_spent']
    budget_collection.update_one({"category": expense_data['expense_category'], "user_id": ObjectId(current_user['_id'])}, {"$set": {"amount": remaining_budget}})

    return {"message": "Expense added successfully"}


@router.get("/expenses/{category}")
def get_expenses_by_category(category: str, current_user: UserInDB = Depends(get_current_user)):
    expenses = list(expense_collection.find({"expense_category": category, "user_id": ObjectId(current_user['_id'])}, {'_id': 0, 'user_id':0}))
    if not expenses:
        raise HTTPException(status_code=404, detail="No expenses found for this category")
    return expenses

@router.get("/all_expenses")
def get_all_expenses(current_user: UserInDB = Depends(get_current_user)):
    all_expenses = [expense for expense in expense_collection.find({"user_id": ObjectId(current_user['_id'])}, {'_id': 0, 'user_id':0})]
    return all_expenses


@router.get("/expenses_summary")
def get_expense_summary(current_user: UserInDB = Depends(get_current_user)):
    summary = {}
    for expense in expense_collection.find({"user_id": ObjectId(current_user['_id'])}):
        category = expense['expense_category']
        if category not in summary:
            summary[category] = 0
        summary[category] += expense['amount_spent']
    return summary

@router.put("/update-expense/{expense_id}")
def update_expense(expense_id: str, updated_expense: Expense, current_user: UserInDB = Depends(get_current_user)):
    updated_expense_data = dict(updated_expense)
    updated_expense_data.pop("user_id", None)  # Remove user_id from the update data

    updated_expense_id = expense_collection.update_one(
        {"_id": ObjectId(expense_id), "user_id": ObjectId(current_user['_id'])},
        {"$set": updated_expense_data}
    )

    if updated_expense_id.modified_count == 1:
        return {"message": f"Expense with ID {expense_id} updated successfully"}
    else:
        raise HTTPException(status_code=404, detail=f"Expense with ID {expense_id} not found")

@router.delete("/delete-expense/{expense_id}")
def delete_expense(expense_id: str, current_user: UserInDB = Depends(get_current_user)):
    deleted_expense = expense_collection.delete_one({"_id": ObjectId(expense_id), "user_id": ObjectId(current_user['_id'])})
    if deleted_expense.deleted_count == 1:
        return {"message": f"Expense with ID {expense_id} deleted successfully"}
    else:
        raise HTTPException(status_code=404, detail=f"Expense with ID {expense_id} not found")
