from flask import Flask, jsonify
from flask_cors import CORS
import pymysql
import os

load_dotenv()
# Configurações do Banco de Dados
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = 3306  # Porta padrão do MySQL

app = Flask(__name__)
CORS(app)  # Permite requisições do Flutter

def conectar_banco():
    """Conecta ao banco de dados MySQL"""
    try:
        conexao = pymysql.connect(
            host=DB_HOST,
            user=DB_USERNAME,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=DB_PORT,
            cursorclass=pymysql.cursors.DictCursor  # Retorna resultados como dicionário
        )
        return conexao
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao conectar ao banco: {e}")
        return None

@app.route('/medicao_consumo', methods=['GET'])
def obter_pessoas():
    conexao = conectar_banco()
    if not conexao:
        return jsonify({"erro": "Erro ao conectar ao banco"}), 500

    try:
        with conexao.cursor() as cursor:
            cursor.execute("SELECT * FROM medicao_consumo;")
            resultados = cursor.fetchall()
            print(resultados)  # Adiciona um print para verificar o JSON retornado
            return jsonify(resultados)
    except pymysql.MySQLError as e:
        return jsonify({"erro": f"Erro ao buscar dados: {e}"}), 500
    finally:
        conexao.close()

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
