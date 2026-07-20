import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    MYSQL_HOST     = os.getenv('MYSQL_HOST', 'localhost')
    MYSQL_USER     = os.getenv('MYSQL_USER', 'root')
    MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '')
    MYSQL_DB       = os.getenv('MYSQL_DB', 'rekomendasi_tipemakeup')
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'dev-secret-key-ganti-ini')
    JWT_ACCESS_TOKEN_EXPIRES = 86400  # 24 jam