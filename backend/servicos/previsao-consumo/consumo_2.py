import os
import pandas as pd
from config.db import get_db_connection

# 🔹 Nome da Tabela
TABLE_NAME = "medicao_consumo"

# 🔹 Caminho do Arquivo CSV
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "dados", "iced_consumo_janeiro_a_marco.csv")

# 🔹 Processar e inserir os dados do CSV no banco
def inserir_dados_csv():
    """Lê o CSV e insere os dados na tabela do banco."""
    if not os.path.exists(CSV_PATH):
        print(f"❌ Arquivo CSV não encontrado: {CSV_PATH}")
        return
    
    conn = None  # Definir a variável 'conn' antes do bloco try
    try:
        # Ler o arquivo CSV
        df = pd.read_csv(CSV_PATH, delimiter=",", skipinitialspace=True)
        print(f"✅ CSV carregado com {len(df)} registros.")

        # Renomear colunas para coincidir com a tabela
        df.columns = ["timestamp", "potA", "potB", "potC", "potTotal", "consumoTotal"]

        # ✅ Converter 'tempo' para DATETIME no formato aceito pelo MySQL
        df["timestamp"] = pd.to_datetime(df["timestamp"], format="%Y/%m/%d %H:%M:%S", errors="coerce")

        # Substituir valores inválidos por None
        df = df.where(pd.notnull(df), None)

        # Verificar se há valores inválidos na coluna 'tempo'
        if df["timestamp"].isnull().any():
            print("⚠️ Existem valores inválidos na coluna 'timestamp', alguns registros serão ignorados.")

        # Conectar ao banco e inserir os dados
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cursor:
                query = f"""
                INSERT INTO `{TABLE_NAME}` (`timestamp`, `potA`, `potB`, `potC`, `potTotal`, `consumoTotal`)
                VALUES (%s, %s, %s, %s, %s, %s);
                """
                print(f"✅ Conectado ao banco de dados, começando a inserção...")
                for _, row in df.iterrows():
                    valores = tuple(None if pd.isna(x) else x for x in row)  # Converte NaN -> None
                    cursor.execute(query, valores)
                    print(f"Inserido: {valores}")  # Log de inserção
                conn.commit()
                print("✅ Dados inseridos com sucesso!")

    except Exception as e:
        print(f"❌ Erro ao inserir dados: {e}")
    
    finally:
        if conn:  # Verifique se a conexão foi aberta antes de tentar fechá-la
            conn.close()
            print("🔌 Conexão fechada.")

# 🔹 Executar a inserção ao rodar o script
if __name__ == "__main__":
    inserir_dados_csv()
