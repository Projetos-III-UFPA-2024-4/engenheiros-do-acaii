import csv
import json
import requests
from datetime import datetime

def enviar_csv_como_json(arquivo_csv, url_destino):
    # Lendo o CSV e estruturando os dados
    dados = []
    with open(arquivo_csv, mode='r', encoding='utf-8') as arquivo:
        leitor_csv = csv.DictReader(arquivo)
        print("Colunas no CSV:", leitor_csv.fieldnames)  # Verifica as colunas no CSV
        for linha in leitor_csv:
            # Converte o valor de Energia solar（kW） para float, tratando a vírgula como ponto
            energia_solar_kw = linha["Energia solar（kW）"].replace(",", ".") if linha["Energia solar（kW）"] else None
            energia_solar_kw = float(energia_solar_kw) if energia_solar_kw else None

            # Corrige o nome da coluna de 'Tempo' para o nome correto no CSV
            try:
                tempo = datetime.strptime(linha["Tempo"].strip(), "%Y/%m/%d %H:%M:%S")
                formatted_tempo = tempo.strftime("%Y-%m-%d %H:%M:%S")  # Formato correto para o banco
            except ValueError:
                formatted_tempo = None  # Caso a data esteja mal formatada

            # Formata os dados para o formato esperado
            dados.append({
                "tempo": formatted_tempo,  # Usando 'tempo' para o campo de data/hora
                "energia_solar_kw": energia_solar_kw,
                "clima": linha["Clima"] or None,
                "feed_in_kw": float(linha["Feed-in（kW）"].replace(",", ".")) if linha["Feed-in（kW）"] else None,
                "compra_kw": float(linha["Compra（kW）"].replace(",", ".")) if linha["Compra（kW）"] else None
            })

    # Enviar os dados lidos como JSON via POST
    resposta = requests.post(url_destino, json=dados)
    
    if resposta.status_code == 200:
        print("CSV convertido e enviado como JSON com sucesso!")
    else:
        print(f"Erro ao enviar JSON: {resposta.status_code} - {resposta.text}")

# Exemplo de uso
enviar_csv_como_json('1a15MarcoEdgar.csv', 'http://localhost:5000/servicos/crud-dados/inversor-json')
