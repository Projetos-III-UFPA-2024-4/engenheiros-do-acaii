import requests

# URL da sua rota para envio do alerta
url = 'http://localhost:5000/servicos/crud-dados/alerta'

# Dados do alerta a serem enviados
dados = {
    'mensagem': 'Alerta!!! O inversor está desarmado'
}

# Envio da requisição POST
response = requests.post(url, json=dados)

# Verificando se o envio foi bem-sucedido
if response.status_code == 200:
    print("Alerta enviado com sucesso!")
else:
    print(f"Falha ao enviar alerta. Status code: {response.status_code}")
