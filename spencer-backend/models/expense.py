from pydantic import BaseModel
from datetime import datetime

class Expense(BaseModel):
    user_id: str
    title: str
    description: str
    amount_spent: float
    expense_category: str
    date_spent: datetime = datetime.now()

    def to_dict(self):
        return self.model_dump()


    