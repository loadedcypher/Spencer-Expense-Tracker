from fastapi import FastAPI
from routes.auth import router as auth_router
from routes.income import router as income_router
from routes.budget import router as budget_router
from routes.expense import router as expense_router

app = FastAPI()

# including the different routes of the app

app.include_router(auth_router)
app.include_router(income_router)
app.include_router(budget_router)
app.include_router(expense_router)




