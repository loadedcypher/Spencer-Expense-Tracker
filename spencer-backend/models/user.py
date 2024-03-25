from pydantic import BaseModel
from typing import List, Optional
from models.expense import Expense
from models.income import Income

class User(BaseModel):
    username: str
    email: str

class UserInDB(User):
    hashed_password: str

class Token(BaseModel):
    access_token: str
    token_type: str


# class User(BaseModel):
#     fullname: str
#     email: str
#     occupation: Optional[str]

#     # A list of where the user gets the monthly income.
#     income_sources: Optional[List[Income]]

#     # A log to store all user expense history.
#     expenses_logs: Optional[List[Expense]]
    
#     # add up the total of all sources of incoming the user has.
#     @property
#     def total_monthly_income(self) -> Optional[float]:
#         if not self.income_sources:
#             return None
#         else:
#             return sum([income.amount for income in self.income_sources])
        
#     amount_left: Optional[float] = total_monthly_income

#     currency: Optional[str]

#     def update_amount_left(self, amount_spent: float):
#         self.amount_left -= amount_spent