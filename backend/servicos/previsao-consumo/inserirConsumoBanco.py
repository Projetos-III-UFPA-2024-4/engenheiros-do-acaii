import os
import pandas as pd
from config.db import get_db_connection
import pymysql

def inserir_consumo_no_banco(csv_file):
    conn = None  # Inicializar a variável 'conn' para evitar o erro de UnboundLocalError
    try:
        # Carregar o arquivo CSV em um DataFrame
        df = pd.read_csv(csv_file)

        # Verificar se todas as colunas necessárias estão presentes no CSV
        required_columns = ["DateTime", "FASE A", "FASE B", "FASE C", "TOTAL", "Consumo"]
        if not all(column in df.columns for column in required_columns):
            print("❌ O arquivo CSV não contém todas as colunas necessárias.")
            return

        # Estabelecer conexão com o banco de dados
        conn = get_db_connection()
        if conn is None:
            print("❌ Não foi possível conectar ao banco de dados.")
            return

        cursor = conn.cursor()

        # Iterar sobre as linhas do DataFrame e inserir no banco de dados
        for _, row in df.iterrows():
            # Converter o datetime para o formato correto para MySQL
            timestamp = pd.to_datetime(row["DateTime"]).strftime('%Y-%m-%d %H:%M:%S')
            potA = row["FASE A"]
            potB = row["FASE B"]
            potC = row["FASE C"]
            potTotal = row["TOTAL"]
            consumoTotal = row["Consumo"]

            # Query para inserir os dados na tabela "medicao_consumo"
            insert_query = """
                INSERT INTO medicao_consumo (timestamp, potA, potB, potC, potTotal, consumoTotal)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (timestamp, potA, potB, potC, potTotal, consumoTotal))

        # Commit para garantir que as inserções sejam salvas no banco de dados
        conn.commit()
        print("✅ Dados inseridos com sucesso!")

    except Exception as e:
        print(f"❌ Ocorreu um erro: {e}")
    finally:
        # Fechar a conexão com o banco de dados se ela foi criada
        if conn:
            conn.close()

if __name__ == "__main__":
    # Caminho para o arquivo CSV dentro da pasta 'dados'
    caminho_csv = "backend/servicos/previsao-consumo/dados/iced_potência_ativa_fev.csv"  # Este caminho deve ser relativo à pasta onde o script está

    # Verificar se o arquivo realmente existe
    if not os.path.isfile(caminho_csv):
        print(f"❌ O arquivo CSV '{caminho_csv}' não foi encontrado.")
    else:
        # Chamar a função para inserir os dados no banco
        inserir_consumo_no_banco(caminho_csv)
