from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from bson.objectid import ObjectId

class ExpenseRequest(BaseModel):
    title: str
    description: Optional[str]
    amount_spent: float
    expense_category: str
    
class Expense(ExpenseRequest):
    user_id: ObjectId
    date_spent: datetime 

    class Config:
        arbitrary_types_allowed = True

    


    