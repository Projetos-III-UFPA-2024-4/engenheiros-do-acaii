import pymysql

# Configurações do Banco de Dados
DB_USERNAME = "engdoacaii"
DB_PASSWORD = "p3smartvolt"
DB_NAME = "smartvolt"
DB_HOST = "smartvoltinstancia.cwt38ijjojpt.us-east-1.rds.amazonaws.com"
DB_PORT = 3306  # Porta padrão do MySQL

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
        print("✅ Conexão bem-sucedida ao banco de dados!")
        return conexao
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao conectar ao banco de dados: {e}")
        return None

def buscar_dados_pessoa():
    """Busca todos os dados da tabela pessoa"""
    conexao = conectar_banco()
    if not conexao:
        return

    try:
        with conexao.cursor() as cursor:
            cursor.execute("SELECT * FROM medicao_consumo;")  # Executa a query
            resultados = cursor.fetchall()  # Busca todos os resultados
            if resultados:
                print("📄 Dados encontrados na tabela 'pessoa':")
                for linha in resultados:
                    print(linha)  # Exibe os dados no terminal
            else:
                print("⚠️ Nenhum dado encontrado na tabela 'pessoa'.")
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao buscar dados: {e}")
    finally:
        conexao.close()  # Fecha a conexão
        print("🔌 Conexão encerrada.")

# Executar a busca dos dados
if __name__ == "__main__":
    buscar_dados_pessoa()
