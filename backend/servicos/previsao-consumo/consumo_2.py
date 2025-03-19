import os
import pandas as pd
from config.db import get_db_connection

# 🔹 Nome da Tabela
TABLE_NAME = "medicao_consumo"

# 🔹 Caminho do Arquivo CSV
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "dados", "teste.csv")

# 🔹 Processar e inserir os dados do CSV no banco
# 🔹 Processar e inserir os dados do CSV no banco
def inserir_dados_csv():
    """Lê o CSV e insere os dados na tabela do banco."""
    if not os.path.exists(CSV_PATH):
        print(f"❌ Arquivo CSV não encontrado: {CSV_PATH}")
        return
    
    conn = None  # Definir a variável 'conn' antes do bloco try
    try:
        # Ler o arquivo CSV com uma verificação mais rigorosa para o cabeçalho
        df = pd.read_csv(CSV_PATH, delimiter=",", skipinitialspace=True, header=0)
        print(f"✅ CSV carregado com {len(df)} registros.")
        
        # Mostrar as primeiras linhas do dataframe para verificar se a coluna 'timestamp' está ok
        print(df.head())

        # Verifique se a coluna "DateTime" está sendo lida corretamente
        if 'DateTime' not in df.columns:
            print("❌ A coluna 'DateTime' não foi encontrada no CSV.")
            return

        # Renomear as colunas para corresponder aos nomes esperados no banco de dados
        df.columns = ["timestamp", "potA", "potB", "potC", "potTotal", "consumoTotal"]

        # Garantir que os dados da coluna 'timestamp' sejam convertidos corretamente
        df['timestamp'] = pd.to_datetime(df['timestamp'], format="%d/%m/%Y %H:%M:%S", errors="coerce")

        # Verificar se houve algum erro na conversão da coluna 'timestamp' para datetime
        if df['timestamp'].isnull().any():
            print(f"⚠️ Existem valores inválidos na coluna 'timestamp'! Esses valores serão ignorados.")

        # Processar as colunas numéricas, exceto 'timestamp'
        for col in df.columns:
            if col != "timestamp":
                df[col] = df[col].astype(str)
                df[col] = df[col].str.replace(',', '.', regex=False)
                df[col] = df[col].astype(float)

        # Substituir valores inválidos por None
        df = df.where(pd.notnull(df), None)

        # Conectar ao banco e inserir os dados
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cursor:
                query = f"""
                INSERT INTO `{TABLE_NAME}` (`hora`, `potA`, `potB`, `potC`, `potTotal`, `consumoTotal`)
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


            
def excluir_dados_tabela():
    """Exclui todos os dados da tabela 'medicao_consumo'."""
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cursor:
                # Usando TRUNCATE para excluir todos os dados de forma eficiente
                query = "TRUNCATE TABLE medicao_consumo;"
                cursor.execute(query)
                conn.commit()
                print("✅ Todos os dados foram excluídos da tabela 'medicao_consumo'.")
        except Exception as e:
            print(f"❌ Erro ao excluir dados: {e}")
        finally:
            conn.close()
            print("🔌 Conexão fechada.")
            
def excluir_dados_tabela_previsao_consumo():
    """Exclui todos os dados da tabela 'previsao_consumo'."""
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cursor:
                # Usando TRUNCATE para excluir todos os dados de forma eficiente
                query = "TRUNCATE TABLE previsao_consumo;"
                cursor.execute(query)
                conn.commit()
                print("✅ Todos os dados foram excluídos da tabela 'mprevisaoconsumo'.")
        except Exception as e:
            print(f"❌ Erro ao excluir dados: {e}")
        finally:
            conn.close()
            print("🔌 Conexão fechada.")
            
import pymysql
from config.db import get_db_connection

def visualizar_dados_do_banco():
    # Estabelece a conexão com o banco de dados
    conn = get_db_connection()
    
    if conn:
        try:
            with conn.cursor() as cursor:
                # Consulta SQL para pegar todas as medições
                query = """
                    SELECT id, hora, consumoTotal
                    FROM medicao_consumo;
                """
                cursor.execute(query)
                
                # Pega todos os resultados
                todas_as_medicoes = cursor.fetchall()

                # Imprime todas as medições
                if todas_as_medicoes:
                    for medicao in todas_as_medicoes:
                        print(f'ID: {medicao["id"]}, Hora: {medicao["hora"]}, Consumo Total: {medicao["consumoTotal"]}')
                else:
                    print("Nenhuma medição encontrada.")
        
        except pymysql.MySQLError as e:
            print(f"❌ Erro ao realizar a consulta: {e}")
        
        finally:
            conn.close()
            
def visualizar_dados_do_banco_producao():
    # Estabelece a conexão com o banco de dados
    conn = get_db_connection()
    
    if conn:
        try:
            with conn.cursor() as cursor:
                # Consulta SQL para pegar todas as medições
                query = """
                    SELECT *
                    FROM previsao_producao;
                """
                cursor.execute(query)
                
                # Pega todos os resultados
                todas_as_medicoes = cursor.fetchall()

                # Imprime todas as medições
                if todas_as_medicoes:
                    for medicao in todas_as_medicoes:
                        print(medicao)
                else:
                    print("Nenhuma medição encontrada.")
        
        except pymysql.MySQLError as e:
            print(f"❌ Erro ao realizar a consulta: {e}")
        
        finally:
            
            conn.close()
def visualizar_dados_do_banco_previsao_consumo():
    # Estabelece a conexão com o banco de dados
    conn = get_db_connection()
    
    if conn:
        try:
            with conn.cursor() as cursor:
                # Consulta SQL para pegar todas as medições
                query = """
                    SELECT *
                    FROM previsao_consumo;
                """
                cursor.execute(query)
                
                # Pega todos os resultados
                todas_as_medicoes = cursor.fetchall()

                # Imprime todas as medições
                if todas_as_medicoes:
                    for medicao in todas_as_medicoes:
                        print(medicao)
                else:
                    print("Nenhuma medição encontrada.")
        
        except pymysql.MySQLError as e:
            print(f"❌ Erro ao realizar a consulta: {e}")
        
        finally:
            conn.close()
            
def visualizar_dados_consumo():
    """Consulta e exibe os dados da coluna 'consumoTotal' da tabela 'medicao_consumo'."""
    conn = get_db_connection()
    if conn:
        try:
            # Consultar apenas a coluna 'consumoTotal' da tabela
            query = "SELECT * FROM previsao_consumo;"
            df = pd.read_sql(query, conn)  # Carregar os dados diretamente para um DataFrame
            print("✅ Dados carregados com sucesso do banco!")
            print(df)  # Exibir os dados da coluna 'consumoTotal'
        except Exception as e:
            print(f"❌ Erro ao executar consulta: {e}")
        finally:
            conn.close()
            print("🔌 Conexão fechada.")
    else:
        print("❌ Não foi possível conectar ao banco.")


def adicionar_coluna_consumo():
    """Adiciona a coluna 'consumo' na tabela 'previsao_consumo' no banco de dados."""
    conn = get_db_connection()
    
    if not conn:
        print("❌ Não foi possível conectar ao banco de dados para adicionar a coluna.")
        return
    
    try:
        with conn.cursor() as cursor:
            # Query para adicionar a coluna 'consumo' à tabela 'previsao_consumo'
            query = """
                ALTER TABLE previsao_consumo
                ADD COLUMN consumo FLOAT;
            """
            # Executar a query
            cursor.execute(query)
            
            # Commit para salvar as alterações no banco de dados
            conn.commit()
            print("✅ Coluna 'consumo' adicionada com sucesso à tabela 'previsao_consumo'!")
    
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao adicionar a coluna no banco de dados: {e}")
    
    finally:
        conn.close()



# 🔹 Executar a inserção ao rodar o script
if __name__ == "__main__":
    #visualizar_dados_do_banco()
    #visualizar_dados_consumo()
    #inserir_dados_csv()
    #excluir_dados_tabela()
    #excluir_dados_tabela_previsao_consumo()
    #visualizar_dados_do_banco_producao()
    visualizar_dados_do_banco_previsao_consumo()
    #adicionar_coluna_consumo()
