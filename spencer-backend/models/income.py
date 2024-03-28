from pydantic import BaseModel
from datetime import datetime
from bson.objectid import ObjectId

class IncomeRequest(BaseModel):
    source: str
    amount: float

class Income(IncomeRequest):
    user_id: ObjectId
    date_received: datetime

    class Config:
        arbitrary_types_allowed = True

class BudgetRequest(BaseModel):
    category: str 
    amount: float

class Budget(BudgetRequest):
    user_id: ObjectId

    class Config:
        arbitrary_types_allowed = True
    