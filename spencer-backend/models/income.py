from pydantic import BaseModel

class Income(BaseModel):
    source: str
    amount: float
    date_to_be_received: str

    def to_dict(self):
        return self.model_dump()