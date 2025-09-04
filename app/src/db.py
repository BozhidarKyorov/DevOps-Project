import os
import psycopg2

DB_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://testuser:testpass@localhost:5432/testdb"
)

def get_connection():
    return psycopg2.connect(DB_URL)

def get_users():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name, email FROM users;")