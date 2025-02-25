import json
import requests  # Certifique-se de instalar esta biblioteca: `pip install requests`

def enviar_json(arquivo_json, url_destino):
    with open(arquivo_json, 'r', encoding='utf-8') as arquivo:
        dados = json.load(arquivo)
    
    resposta = requests.post(url_destino, json=dados)
    
    if resposta.status_code == 200:
        print("JSON enviado com sucesso!")
    else:
        print(f"Erro ao enviar JSON: {resposta.status_code} - {resposta.text}")

# Exemplo de uso
enviar_json('estadoNormal.json', 'http://localhost:5000/servicos/crud-dados/inversor-json')
