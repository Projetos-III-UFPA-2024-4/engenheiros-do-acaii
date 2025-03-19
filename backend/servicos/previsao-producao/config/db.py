import os
import pymysql
from dotenv import load_dotenv

# Carregar variáveis de ambiente do arquivo .env
load_dotenv()

# 🔹 Configuração do Banco de Dados MySQL
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")

# 🔹 Criar conexão com o MySQL
def get_db_connection():
    """Estabelece e retorna uma conexão com o banco de dados MySQL."""
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            user=DB_USERNAME,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        print(f"✅ Conectado ao banco de dados: {DB_NAME}")
        return conn
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao conectar ao banco de dados: {e}")
        return None
