import subprocess
from flask import Flask, request, jsonify

app = Flask(__name__)

# Função para executar o script 'modelo_prophet.py' 
def executar_modelo_prophet():
    try:
        subprocess.run(['python', 'backend/servicos/previsao-producao/modelo_prophet.py'], check=True)
        print("Modelo Prophet executado com sucesso!")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar modelo Prophet: {e}")

# Função para executar o script 'modelo_consumo.py'
def executar_modelo_consumo():
    try:
        subprocess.run(['python', 'backend/servicos/previsao-consumo/modelo_consumo.py'], check=True)
        print("Modelo Consumo executado com sucesso!")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar modelo Consumo: {e}")

# Rota para '/servicos/crud-dados/inversor-json'
@app.route('/servicos/crud-dados/inversor-json', methods=['POST'])
def inversor_json():
    # Aqui você pode acessar o JSON enviado para a rota
    dados_inversor = request.get_json()  # Recebe o JSON
    print("Dados recebidos para inversor:", dados_inversor)
    
    # Executa o modelo Prophet
    executar_modelo_prophet()
    
    return jsonify({"status": "Modelo Prophet executado com sucesso!"}), 200

# Rota para '/servicos/crud-dados/medidor-json'
@app.route('/servicos/crud-dados/medidor-json', methods=['POST'])
def medidor_json():
    # Aqui você pode acessar o JSON enviado para a rota
    dados_medidor = request.get_json()  # Recebe o JSON
    print("Dados recebidos para medidor:", dados_medidor)
    
    # Executa o modelo Consumo
    executar_modelo_consumo()
    
    return jsonify({"status": "Modelo Consumo executado com sucesso!"}), 200

# Inicia o servidor Flask
if __name__ == '__main__':
    app.run(debug=True, port=5001)  # Flask rodando na porta 5001
