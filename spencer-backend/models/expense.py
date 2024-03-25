from pydantic import BaseModel
from datetime import datetime

class ExpenseCategory(BaseModel):
    name: str
    description: str
    budget: float
    color: str

    def to_dict(self):
        return self.model_dump()

class Expense(BaseModel):
    title: str
    description: str
    amount_spent: float
    expense_category: str
    date_spent: datetime = datetime.now()

    def to_dict(self):
        return self.model_dump()


    