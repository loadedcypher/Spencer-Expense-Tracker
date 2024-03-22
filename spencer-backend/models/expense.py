from pydantic import BaseModel

class ExpenseCategory(BaseModel):
    name: str
    description: str
    budget: float
    color: str

class Expense(BaseModel):
    title: str
    description: str
    amount_spent: float
    expense_category: str
    date_spent: str


    