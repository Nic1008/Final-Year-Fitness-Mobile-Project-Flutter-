from pymongo import MongoClient

MONGO_URL = "mongodb+srv://nicholasnio10_db_user:08102003_Nic@cluster0.qfeulpt.mongodb.net/?appName=Cluster0"

client = MongoClient(MONGO_URL)

db = client["test_db"]
col = db["test_col"]

result = col.insert_one({"msg": "Hello MongoDB"})
print("Inserted ID:", result.inserted_id)

print("Collections:", db.list_collection_names())
