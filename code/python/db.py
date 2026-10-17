import psycopg2
from psycopg2.extras import RealDictCursor

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "university",
    "user": "postgres",
    "password": "",
}


def get_connection():
    return psycopg2.connect(cursor_factory=RealDictCursor, **DB_CONFIG)
