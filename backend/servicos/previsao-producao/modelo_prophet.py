# Imports iniciais
import pandas as pd
import matplotlib.pyplot as plt
from prophet import Prophet
import joblib
from dotenv import load_dotenv
from sklearn.metrics import mean_absolute_error, mean_squared_error
import numpy as np
import os
from sqlalchemy import create_engine
import pymysql

# Conexão com Banco
load_dotenv()

# Configuração do Banco de Dados MySQL 
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")
TABLE_NAME = os.getenv("TABLE_NAME")

# Criar a conexão com MySQL usando SQLAlchemy
engine = create_engine(f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}")

# Definir a query SQL para buscar os dados
query = "SELECT * FROM medicao_producao"

# Ler os dados diretamente do banco para um DataFrame Pandas
df = pd.read_sql(query, con=engine)
print("Primeiras linhas do DataFrame:")
print(df.head())

# Preparando dados para Prophet
df = df[["tempo", "energia_solar_kw"]].copy()
df.columns = ["ds", "y"]

# Remover duplicatas de timestamp
df = df.drop_duplicates(subset=["ds"])

# CONVERSÃO DE Wh PARA kWh (dividindo por 1000) e tratamento de valores zero
df["y"] = df["y"] / 1000
df = df[df["y"] > 0]  # Remove valores zero que causam problemas com log

print("\nÚltimas linhas do DataFrame após preparação e conversão para kWh:")
print(df.tail())

# Tratamento da base de dados
print("\nInformações do DataFrame:")
df.info()

# Visualiza os registros com valores nulos em "y"
print("\nLinhas com valores nulos em 'y':")
print(df[df["y"].isnull()])

# Remove registros com valores nulos
df = df.dropna()

print("\nShape do DataFrame após limpeza:")
print(df.shape)

# Transformação logarítmica para lidar com valores positivos
# df["y_log"] = np.log(df["y"])

# Verificar se há dados suficientes
if len(df) < 2:
    raise ValueError("Dados insuficientes após limpeza. Necessário pelo menos 2 observações.")

# Treinando modelo com parâmetros ajustados
modelo = Prophet(
    changepoint_prior_scale=0.05,  # Reduz flexibilidade para evitar overfitting
    seasonality_prior_scale=0.1,    # Controla força da sazonalidade
    yearly_seasonality=False,      # Desativa sazonalidade anual se não for relevante
    daily_seasonality=True,        # Mantém sazonalidade diária
    weekly_seasonality=True        # Mantém sazonalidade semanal
)

# Criar DataFrame para treino com as colunas esperadas pelo Prophet
df_treino = df[["ds", "y"]].copy()
df_treino.columns = ["ds", "y"]

try:
    modelo.fit(df_treino)
except Exception as e:
    print(f"\nErro ao treinar o modelo: {str(e)}")
    raise

# Fazer previsão para os próximos 30 dias (1440 períodos de 10 minutos)
#futuro = modelo.make_future_dataframe(periods=1440, freq="10min")
futuro = modelo.make_future_dataframe(periods=1, freq="10min")
previsao = modelo.predict(futuro)

# Reverter a transformação logarítmica e garantir valores não-negativos
# previsao["yhat"] = np.exp(previsao["yhat"]).clip(lower=0)

# Preparar dados reais para comparação (sem transformação log)
df_real = df.copy()

# Métricas de Avaliação
df_comparacao = pd.merge(df_real, previsao[["ds", "yhat"]], on="ds", how="inner")

# Verificar se há dados para cálculo de métricas
if len(df_comparacao) == 0:
    raise ValueError("Nenhum dado para cálculo de métricas. Verifique a junção dos DataFrames.")

# Calcular métricas de erro
try:
    mae = mean_absolute_error(df_comparacao["y"], df_comparacao["yhat"])
    mse = mean_squared_error(df_comparacao["y"], df_comparacao["yhat"])
    rmse = np.sqrt(mse)
    mape = np.mean(np.abs((df_comparacao["y"] - df_comparacao["yhat"]) / df_comparacao["y"])) * 100
except Exception as e:
    print(f"\nErro ao calcular métricas: {str(e)}")
    raise

print(previsao["yhat"])

# Exibir resultados
print("\n🔹 Métricas de Avaliação do Modelo Prophet (em kWh):")
print(f"📌 MAE  (Erro Absoluto Médio): {mae:.4f} kWh")
print(f"📌 MSE  (Erro Quadrático Médio): {mse:.4f} kWh²")
print(f"📌 RMSE (Raiz do Erro Quadrático Médio): {rmse:.4f} kWh")
print(f"📌 MAPE (Erro Percentual Absoluto Médio): {mape:.2f}%")

# Visualização das previsões
plt.figure(figsize=(15, 6))
plt.plot(df_comparacao["ds"], df_comparacao["y"], label="Valores Reais", color="blue", alpha=0.5)
plt.plot(previsao["ds"], previsao["yhat"], label="Previsões", color="red", alpha=0.7)
plt.fill_between(previsao["ds"], previsao["yhat_lower"], previsao["yhat_upper"], 
                 color="pink", alpha=0.3, label="Intervalo de Confiança")
plt.title("Comparação entre Valores Reais e Previsões")
plt.xlabel("Data")
plt.ylabel("Consumo")
plt.legend()
plt.grid(True)
plt.show()

# Salvar o modelo para uso futuro
joblib.dump(modelo, 'modelo_prophet_consumo.pkl')
print("\nModelo salvo com sucesso como 'modelo_prophet_consumo.pkl'")

# 🔹 Criar conexão com o MySQL
conn = pymysql.connect(
    host=DB_HOST,
    user=DB_USERNAME,
    password=DB_PASSWORD,
    database=DB_NAME,
)
cursor = conn.cursor()

query = f"""
INSERT INTO previsao_producao (`geracao (kwh)`, `timestamp`)
VALUES (%s, %s)
"""

# 🔹 Inserir previsões no banco usando apenas ds e yhat, renomeados na query
for _, row in previsao.iterrows():
    cursor.execute(query, (row["yhat"], row["ds"]))

# 🔹 Confirmar e fechar conexão
conn.commit()
cursor.close()
conn.close()

# 🔹 Criar conexão com MySQL
conn = pymysql.connect(
    host=DB_HOST,
    user=DB_USERNAME,
    password=DB_PASSWORD,
    database=DB_NAME
)
cursor = conn.cursor()

# 🔹 Query SQL para buscar as últimas 10 linhas inseridas
query = f"""
SELECT * FROM previsao_producao
ORDER BY timestamp DESC
LIMIT 10;
"""

# 🔹 Executar a consulta
cursor.execute(query)

# 🔹 Obter os resultados e armazenar em um DataFrame Pandas
colunas = [desc[0] for desc in cursor.description]  # Captura os nomes das colunas
resultados = cursor.fetchall()
df = pd.DataFrame(resultados, columns=colunas)  # Criar DataFrame com os resultados

# 🔹 Fechar conexão
cursor.close()
conn.close()

# 🔹 Mostrar os dados no terminal
print("\n🔹 Últimas 10 Previsões Inseridas no Banco:")
print(df)