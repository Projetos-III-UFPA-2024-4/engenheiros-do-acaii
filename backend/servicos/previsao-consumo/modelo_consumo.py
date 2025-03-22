# -*- coding: utf-8 -*-
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from prophet import Prophet
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import train_test_split
import pymysql
from dotenv import load_dotenv
from datetime import timedelta

# Carregar variáveis de ambiente do arquivo .env
load_dotenv()

# 🔹 Configuração do Banco de Dados MySQL
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")

# Função para estabelecer conexão com o banco de dados MySQL
def get_db_connection():
    """Estabelece e retorna uma conexão com o banco de dados MySQL."""
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            user=DB_USERNAME,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor  # Retorna os resultados como dicionário
        )
        print(f"✅ Conectado ao banco de dados: {DB_NAME}")
        return conn
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao conectar ao banco de dados: {e}")
        return None

# Função para visualizar dados do banco e carregar em um DataFrame
def visualizar_dados_do_banco():
    # Estabelece a conexão com o banco de dados
    conn = get_db_connection()
    
    if not conn:
        print("❌ Não foi possível conectar ao banco de dados.")
        return None

    try:
        with conn.cursor() as cursor:
            # Consulta SQL para pegar todas as medições
            query = """
                SELECT id, timestamp, consumoTotal
                FROM medicao_consumo;
            """
            cursor.execute(query)
            
            # Pega todos os resultados
            todas_as_medicoes = cursor.fetchall()

            # Verifica se há resultados
            if todas_as_medicoes:
                # Converte para um DataFrame do pandas para uso em modelos
                df = pd.DataFrame(todas_as_medicoes)
                return df  # Retorna o DataFrame com os dados
            else:
                print("Nenhuma medição encontrada.")
                return None
        
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao realizar a consulta: {e}")
        return None
    
    finally:
        conn.close()

# Função para salvar previsões no banco de dados
def salvar_previsao_no_banco(forecast_test):
    """Insere as previsões do modelo Prophet na tabela 'previsao_consumo'."""
    conn = get_db_connection()
    
    if not conn:
        print("❌ Não foi possível conectar ao banco de dados para salvar as previsões.")
        return
    
    try:
        with conn.cursor() as cursor:
            # Query para inserir as previsões na tabela previsao_consumo
            query = """
                INSERT INTO previsao_consumo (timestamp, consumo)
                VALUES (%s, %s)
            """
            
            # Itera sobre as previsões e insere no banco
            for _, row in forecast_test.iterrows():
                timestamp = row['ds']
                previsao = row['yhat']
                cursor.execute(query, (timestamp, previsao))
            
            # Commit para salvar as alterações no banco de dados
            conn.commit()
            print("✅ Previsões salvas com sucesso no banco de dados!")
    
    except pymysql.MySQLError as e:
        print(f"❌ Erro ao salvar as previsões no banco de dados: {e}")
    
    finally:
        conn.close()

# Função para treinar, testar e prever os próximos 15 dias
def treinar_e_prever():
    # Carregar dados do banco
    data = visualizar_dados_do_banco()
    if data is None:
        return

    # Preprocessamento dos dados
    data["consumoTotal"] = pd.to_numeric(data["consumoTotal"], errors='coerce')
    data["consumoTotal"] = data["consumoTotal"].astype(str)
    data["consumoTotal"] = data["consumoTotal"].str.replace(',', '.', regex=False)
    data["consumoTotal"] = data["consumoTotal"].astype(float)
    data['timestamp'] = pd.to_datetime(data['timestamp'])

    # Selecionar as colunas necessárias para o Prophet
    df = data[['timestamp', 'consumoTotal']].rename(columns={'timestamp': 'ds', 'consumoTotal': 'y'})

    # Garantir que a série temporal tenha uma frequência uniforme
    df = df.set_index("ds").asfreq("10min").reset_index()

    # Dividir os dados aleatoriamente em 80% treino e 20% teste
    train, test = train_test_split(df, test_size=0.2)

    # Ordenar os dados pelo timestamp dentro de cada conjunto para manter a coerência temporal
    train = train.sort_values(by="ds")
    test = test.sort_values(by="ds")

    # Criar e treinar o modelo Prophet
    modelo = Prophet()
    modelo.fit(train)

    # Criar um dataframe com datas futuras para o período de teste
    future = modelo.make_future_dataframe(periods=len(test), freq='10min')

    # Fazer a previsão
    forecast = modelo.predict(future)

    # Selecionar apenas as previsões correspondentes ao período de teste
    forecast_test = forecast.iloc[-len(test):]

    # Exibir as primeiras previsões
    print(forecast_test[['ds', 'yhat']].head())

    # Calcular as métricas de avaliação
    test['y'] = test['y'].fillna(0)
    nan_count = test['y'].isna().sum()
    print(f"NaN na coluna 'y': {nan_count}")

    mae = mean_absolute_error(test['y'], forecast_test['yhat'])
    mse = mean_squared_error(test['y'], forecast_test['yhat'])
    rmse = np.sqrt(mse)

    print(f"MAE: {mae:.2f}")
    print(f"MSE: {mse:.2f}")
    print(f"RMSE: {rmse:.2f}")

    plt.figure(figsize=(12, 6))
    # Plotar valores reais do conjunto de teste
    plt.plot(test['ds'], test['y'], label='Valores Reais', color='blue')
    # Plotar previsões do modelo
    plt.plot(forecast_test['ds'], forecast_test['yhat'], label='Previsão Prophet', color='red')
    plt.title("Comparação: Previsões vs. Valores Reais")
    plt.xlabel("Data")
    plt.ylabel("Consumo Total de Energia")
    plt.legend()
    plt.show()

    # Plotar os componentes da previsão (tendência e sazonalidade)
    modelo.plot_components(forecast)
    plt.show()

    # Salvar as previsões no banco
    salvar_previsao_no_banco(forecast_test)

    # Agora prever os próximos 15 dias com base na última medição
    conn = get_db_connection()
    with conn.cursor() as cursor:
        query = """
            SELECT timestamp
            FROM medicao_consumo
            ORDER BY timestamp DESC
            LIMIT 1;
        """
        cursor.execute(query)
        ultima_medicao = cursor.fetchone()

        if ultima_medicao:
            ultima_data = ultima_medicao['timestamp']
            print(f"Última medição encontrada: {ultima_data}")

            # Gerar datas futuras para os próximos 15 dias
            future_dates = [ultima_data + timedelta(minutes=10 * i) for i in range(1, 15 * 24 * 6 + 1)]  # 15 dias * 24 horas * 6 intervalos de 10 minutos por hora
            future_df = pd.DataFrame(future_dates, columns=["ds"])

            # Prever para os próximos 15 dias
            forecast_15dias = modelo.predict(future_df)

            # Exibir as previsões do próximo dia
            print(forecast_15dias[['ds', 'yhat']].tail())

            # Salvar as previsões futuras no banco
            salvar_previsao_no_banco(forecast_15dias[['ds', 'yhat']])
        else:
            print("❌ Nenhuma medição encontrada para prever os próximos dias.")

    # Fechar a conexão com o banco
    conn.close()

# Chame a função para treinar, testar e prever os próximos 15 dias
treinar_e_prever()
