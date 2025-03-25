import csv
import json
import requests
from datetime import datetime

def enviar_csv_como_json_medidor(arquivo_csv, url_destino):
    # Lendo o CSV e estruturando os dados
    dados = []
    with open(arquivo_csv, mode='r', encoding='utf-8') as arquivo:
        leitor_csv = csv.DictReader(arquivo)
        for linha in leitor_csv:
            # Converte o valor de DateTime para o formato esperado no banco (YYYY-MM-DD HH:MM:SS)
            try:
                timestamp = datetime.strptime(linha["DateTime"], "%d/%m/%Y %H:%M:%S")
                formatted_timestamp = timestamp.strftime("%Y-%m-%d %H:%M:%S")  # Formato: "YYYY-MM-DD HH:MM:SS"
            except ValueError:
                formatted_timestamp = None  # Caso a data esteja mal formatada

            # Formata os dados para o formato esperado
            dados.append({
                "timestamp": formatted_timestamp,  # Data e hora formatadas corretamente
                "potA": float(linha["FASE A"].replace(",", ".")) if linha["FASE A"] else None,
                "potB": float(linha["FASE B"].replace(",", ".")) if linha["FASE B"] else None,
                "potC": float(linha["FASE C"].replace(",", ".")) if linha["FASE C"] else None,
                "potTotal": float(linha["TOTAL"].replace(",", ".")) if linha["TOTAL"] else None,
                "consumoTotal": float(linha["Consumo"].replace(",", ".")) if linha["Consumo"] else None
            })

    # Enviar os dados lidos como JSON via POST
    resposta = requests.post(url_destino, json=dados)
    
    if resposta.status_code == 200:
        print("CSV convertido e enviado como JSON com sucesso!")
    else:
        print(f"Erro ao enviar JSON: {resposta.status_code} - {resposta.text}")

# Exemplo de uso
enviar_csv_como_json_medidor('teste.csv', 'http://localhost:5000/servicos/crud-dados/medidor-json')
