from pymongo import MongoClient

client: MongoClient = MongoClient('mongodb://localhost:27017')
db = client['Spencer']
users_collection = db['Users']
income_collection = db['Income']
budget_collection = db['Budget']
expense_collection = db['Expense']