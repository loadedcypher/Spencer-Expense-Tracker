from pydantic import BaseModel
from typing import List, Optional
from models.expense import Expense
from models.income import Income

class User(BaseModel):
    fullname: str
    email: str
    occupation: str

    # A list of where the user gets the monthly income.
    income_sources: List[Income]

    # A log to store all user expense history.
    expenses_logs: List[Expense]
    
    # add up the total of all sources of incoming the user has.
    @property
    def total_monthly_income(self) -> Optional[float]:
        if not self.income_sources:
            return None
        else:
            return sum([income.amount for income in self.income_sources])
        
    amount_left: float = total_monthly_income

    currency: str

    def update_amount_left(self, amount_spent: float):
        self.amount_left -= amount_spent