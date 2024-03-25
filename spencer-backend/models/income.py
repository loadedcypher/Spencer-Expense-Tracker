from pydantic import BaseModel
from datetime import datetime

class Income(BaseModel):
    user_id: str
    source: str
    amount: float
    date_received: datetime = datetime.now()

    def to_dict(self):
        return self.model_dump()
    
class Budget(BaseModel):
    category: str
    amount: float