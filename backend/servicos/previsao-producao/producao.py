import os
import pandas as pd
from config.db import get_db_connection

# 🔹 Nome da Tabela
TABLE_NAME = "medicao_producao"

# 🔹 Caminho do Arquivo CSV
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "dados", "teste.csv")

# 🔹 Processar e inserir os dados do CSV no banco
def inserir_dados_csv():
    """Lê o CSV e insere os dados na tabela do banco."""
    if not os.path.exists(CSV_PATH):
        print(f"❌ Arquivo CSV não encontrado: {CSV_PATH}")
        return
    
    try:
        # Ler o arquivo CSV
        df = pd.read_csv(CSV_PATH, delimiter=",", skipinitialspace=True)

        # Renomear colunas para coincidir com a tabela
        df.columns = ["tempo", "energia_solar_kw", "clima", "feed_in_kw", "compra_kw"]

        # ✅ Converter 'tempo' para DATETIME no formato aceito pelo MySQL
        df["tempo"] = pd.to_datetime(df["tempo"], format="%Y/%m/%d %H:%M:%S", errors="coerce")

        # Substituir valores inválidos por None
        df = df.where(pd.notnull(df), None)

        # Verificar se há valores inválidos na coluna 'tempo'
        if df["tempo"].isnull().any():
            print("⚠️ Existem valores inválidos na coluna 'tempo', alguns registros serão ignorados.")

        # Conectar ao banco e inserir os dados
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cursor:
                query = f"""
                INSERT INTO `{TABLE_NAME}` (`tempo`, `energia_solar_kw`, `clima`, `feed_in_kw`, `compra_kw`)
                VALUES (%s, %s, %s, %s, %s);
                """
                for _, row in df.iterrows():
                    valores = tuple(None if pd.isna(x) else x for x in row)  # Converte NaN -> None
                    cursor.execute(query, valores)
                
                conn.commit()
                print("✅ Dados inseridos com sucesso!")

    except Exception as e:
        print(f"❌ Erro ao inserir dados: {e}")
    
    finally:
        if conn:
            conn.close()
            print("🔌 Conexão fechada.")

# 🔹 Executar a inserção ao rodar o script
if __name__ == "__main__":
    inserir_dados_csv()
