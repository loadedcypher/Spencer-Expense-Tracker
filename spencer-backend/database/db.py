from pymongo import MongoClient

client: MongoClient = MongoClient('mongodb://localhost:27017')
db = client['Spencer']
users_collection = db['Users']