from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
import pandas as pd
import time

# === CONFIGURAÇÕES ===
CPF = "05795503207"  # CPF SEM PONTOS OU TRAÇOS
DATA_NASCIMENTO = "16/05/2002"  # Data de nascimento COM BARRAS (Respeitando máscara)
VALOR_CONTA_CONTRATO = "003025802461|2001090392"  # Insira o valor exato da conta contrato
URL_SITE = "https://pa.equatorialenergia.com.br/sua-conta/historico-de-consumo/"  # URL do site
CAMINHO_CSV = r"C:\david\engenheiros-do-acaii\backend\servicos\previsao-consumo\consumo.csv"  # Defina o caminho do CSV no seu computador
MODO_VISIVEL = True  # Defina como False para rodar em segundo plano

# === CONFIGURAÇÃO DO DRIVER ===
chrome_options = webdriver.ChromeOptions()
if not MODO_VISIVEL:
    chrome_options.add_argument("--headless")  # Executa sem abrir o navegador

driver = webdriver.Chrome(options=chrome_options)
wait = WebDriverWait(driver, 30)  # Aumentamos o tempo de espera para 30 segundos

try:
    # 1. ACESSAR O SITE
    driver.get(URL_SITE)
    print("🌐 Acessando o site...")

    # 2. FECHAR POP-UP (Clique em "CONTINUAR NO SITE")
    try:
        botao_continuar = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, "btn-default")))
        botao_continuar.click()
        print("✅ Pop-up fechado com sucesso.")
    except:
        print("⚠️ Pop-up não encontrado! Tentando com JavaScript...")
        try:
            driver.execute_script("document.querySelector('.btn-default').click();")
            print("✅ Pop-up fechado via JavaScript.")
        except:
            print("❌ Erro: Não foi possível fechar o pop-up.")

    # 3. INSERIR CPF
    campo_cpf = wait.until(EC.presence_of_element_located((By.ID, "identificador-otp")))
    campo_cpf.clear()
    time.sleep(1)

    for char in CPF:
        campo_cpf.send_keys(char)
        time.sleep(0.1)  # Pequeno delay para evitar problemas com a máscara

    campo_cpf.send_keys(Keys.TAB)  # Usa TAB para sair do campo e evitar problemas
    print("✅ CPF inserido corretamente.")

    # 4. CLICAR NO PRIMEIRO BOTÃO "ENTRAR"
    try:
        botao_entrar = wait.until(EC.element_to_be_clickable((By.ID, "envia-identificador-otp")))
        botao_entrar.click()
        print("✅ Primeiro botão 'Entrar' clicado.")
    except:
        print("⚠️ Botão 'Entrar' não encontrado! Tentando via JavaScript...")
        try:
            driver.execute_script("document.getElementById('envia-identificador-otp').click();")
            print("✅ Botão 'Entrar' clicado via JavaScript.")
        except:
            print("❌ Erro: Não foi possível clicar no primeiro botão 'Entrar'.")

    # 5. ESPERAR E INSERIR DATA DE NASCIMENTO
    try:
        campo_data = wait.until(EC.presence_of_element_located((By.ID, "senha-identificador")))
        campo_data.clear()
        time.sleep(1)

        for char in DATA_NASCIMENTO:
            campo_data.send_keys(char)
            time.sleep(0.1)  # Pequeno delay para evitar problemas com a máscara

        campo_data.send_keys(Keys.TAB)  # Usa TAB para confirmar a entrada
        print("✅ Data de nascimento inserida corretamente.")
    except:
        print("⚠️ Campo de Data de Nascimento não encontrado! Tentando via JavaScript...")
        try:
            driver.execute_script(f"document.getElementById('senha-identificador').value = '{DATA_NASCIMENTO}';")
            driver.execute_script("document.getElementById('senha-identificador').dispatchEvent(new Event('change'));")
            print("✅ Data de nascimento inserida via JavaScript.")
        except:
            print("❌ Erro: Não foi possível inserir a Data de Nascimento.")

    # 6. CLICAR NO SEGUNDO BOTÃO "ENTRAR" E GARANTIR QUE O PROCESSAMENTO OCORREU
    try:
        botao_entrar_novamente = wait.until(EC.element_to_be_clickable((By.ID, "envia-identificador")))
        botao_entrar_novamente.click()
        print("✅ Segundo botão 'Entrar' clicado.")

        # 🔄 Esperar até que o botão mude para "Aguarde"
        try:
            print("⏳ Aguardando o botão mudar para 'Aguarde'...")
            wait.until(EC.text_to_be_present_in_element((By.ID, "envia-identificador"), "Aguarde"))
            print("✅ O botão mudou para 'Aguarde'.")
        except:
            print("⚠️ O botão não mudou para 'Aguarde'. Tentando clicar novamente...")
            botao_entrar_novamente.click()
            time.sleep(2)  # Pequena pausa antes de verificar novamente

        # 🔄 ESPERAR O PROCESSO DE CARREGAMENTO ANTES DA CONTA CONTRATO
        try:
            print("⏳ Aguardando o pop-up de 'Processando' aparecer...")
            wait.until(EC.presence_of_element_located((By.CLASS_NAME, "processando-popup")))  # Ajuste a classe se necessário

            print("⏳ Aguardando o pop-up de 'Processando' desaparecer...")
            wait.until(EC.invisibility_of_element_located((By.CLASS_NAME, "processando-popup")))  # Espera ele sumir
            print("✅ Processo de carregamento concluído.")

        except:
            print("⚠️ O pop-up de 'Processando' não foi encontrado, continuando mesmo assim...")

        # 🔄 Verificar se o botão "Entrar" reapareceu
        try:
            botao_entrar_novamente = driver.find_element(By.ID, "envia-identificador")
            if botao_entrar_novamente.is_displayed():
                print("⚠️ O botão 'Entrar' reapareceu! Tentando clicar novamente...")
                botao_entrar_novamente.click()
                time.sleep(3)  # Espera extra para garantir o processamento
        except:
            print("✅ O botão 'Entrar' não reapareceu, continuando normalmente.")

    except:
        print("⚠️ Segundo botão 'Entrar' não encontrado! Tentando via JavaScript...")
        try:
            driver.execute_script("document.getElementById('envia-identificador').click();")
            print("✅ Segundo botão 'Entrar' clicado via JavaScript.")
        except:
            print("❌ Erro: Não foi possível clicar no segundo botão 'Entrar'.")


    # 7. ESPERAR E SELECIONAR A CONTA CONTRATO PELO VALOR
    try:
        print("⏳ Aguardando a exibição da área de seleção de conta contrato...")

        wait.until(EC.presence_of_element_located((By.CLASS_NAME, "select-wrap")))
        wait.until(EC.visibility_of_element_located((By.CLASS_NAME, "select-wrap")))

        print("✅ A área de seleção de conta contrato apareceu.")

        # Agora, esperar até que o <select> seja carregado
        wait.until(EC.presence_of_element_located((By.ID, "conta_contrato")))
        wait.until(EC.visibility_of_element_located((By.ID, "conta_contrato")))
        wait.until(EC.element_to_be_clickable((By.ID, "conta_contrato")))

        time.sleep(2)  # Tempo extra para evitar erro "stale element reference"
        select_conta = driver.find_element(By.ID, "conta_contrato")
        select = Select(select_conta)

        # 🚀 SELECIONAR A CONTA PELO VALOR
        try:
            select.select_by_value(VALOR_CONTA_CONTRATO)
            print(f"✅ Conta contrato selecionada pelo valor: {VALOR_CONTA_CONTRATO}")
        except:
            print(f"⚠️ Valor {VALOR_CONTA_CONTRATO} não encontrado, tentando selecionar a segunda conta...")

            opcoes = select.options
            if len(opcoes) > 1:
                select.select_by_index(1)
                print(f"✅ Segunda conta contrato selecionada: {opcoes[1].text}")
            else:
                print(f"⚠️ Apenas uma conta contrato disponível: {opcoes[0].text}")

    except Exception as e:
        print(f"❌ Erro: O campo de conta contrato demorou muito para aparecer. Detalhes: {e}")


    # 8. SALVAR DADOS EM CSV
    # print("⏳ Salvando o arquivo CSV...")
    # df.to_csv(CAMINHO_CSV, encoding="utf-8", index_label="Mês")
    # print(f"✅ Arquivo CSV salvo com sucesso em: {CAMINHO_CSV}")

    #EXCLUIR A ETAPA 9 EM DIANTE


    # 8. ESPERAR O GRÁFICO CARREGAR (DETECTANDO O <CANVAS> CORRETAMENTE)
    print("⏳ Aguardando o carregamento do gráfico...")

    while True:
        try:
            # Verifica se o elemento <canvas> do gráfico está presente e visível
            canvas_element = wait.until(EC.presence_of_element_located((By.ID, "historico-consumo")))
            canvas_visible = wait.until(EC.visibility_of_element_located((By.ID, "historico-consumo")))

            if canvas_element and canvas_visible:
                print("✅ O gráfico foi detectado na tela!")
                break  # Sai do loop pois o gráfico foi encontrado

        except Exception as e:
            pass  # Continua tentando até que o gráfico apareça

        time.sleep(2)  # Aguarda 2 segundos antes de tentar novamente

    # 9. EXTRAIR DADOS DO GRÁFICO
    try:
        print("⏳ Tentando extrair os dados do gráfico...")

        script_extracao = """
        var charts = Object.values(Chart.instances);
        if (charts.length > 0) {
            var chart = charts[0];  // Pega o primeiro gráfico carregado
            return {
                labels: chart.data.labels,
                datasets: chart.data.datasets.map(ds => ({label: ds.label, data: ds.data}))
            };
        } else {
            return null;
        }
        """

        dados = driver.execute_script(script_extracao)

        # Verificar se há dados extraídos
        if not dados or not dados["labels"] or not dados["datasets"]:
            print("⚠️ Nenhum dado foi encontrado no gráfico. Tentando novamente após 3 segundos...")
            time.sleep(3)  # Dá mais tempo para carregamento assíncrono
            dados = driver.execute_script(script_extracao)  # Tenta extrair os dados novamente

            if not dados or not dados["labels"] or not dados["datasets"]:
                print("❌ Falha ao extrair dados do gráfico após tentativa extra.")
                df = None  # Definir df como None para evitar erro ao salvar
            else:
                print("✅ Dados extraídos na segunda tentativa!")

        if dados:
            labels = dados["labels"]
            datasets = dados["datasets"]

            # Criar o DataFrame com os dados do gráfico
            df = pd.DataFrame({ds["label"]: ds["data"] for ds in datasets}, index=labels)

            print("✅ Dados extraídos com sucesso!")

    except Exception as e:
        print(f"❌ Erro ao extrair dados do gráfico: {e}")
        df = None  # Evita erro ao tentar salvar se a extração falhar

    # 10. SALVAR DADOS EM CSV
    if df is not None:
        try:
            print("⏳ Salvando o arquivo CSV...")
            df.to_csv(CAMINHO_CSV, encoding="utf-8", index_label="Mês")
            print(f"✅ Arquivo CSV salvo com sucesso em: {CAMINHO_CSV}")
        except Exception as e:
            print(f"❌ Erro ao salvar o arquivo CSV: {e}")
    else:
        print("⚠️ Nenhum dado foi extraído, arquivo CSV não será salvo.")

    # 11. SALVAR DADOS EM CSV
    if df is not None:
        try:
            print("⏳ Salvando o arquivo CSV...")
            df.to_csv(CAMINHO_CSV, encoding="utf-8", index_label="Mês")
            print(f"✅ Arquivo CSV salvo com sucesso em: {CAMINHO_CSV}")
        except Exception as e:
            print(f"❌ Erro ao salvar o arquivo CSV: {e}")
    else:
        print("⚠️ Nenhum dado foi extraído, arquivo CSV não será salvo.")


finally:
    if MODO_VISIVEL:
        input("Pressione Enter para fechar o navegador...")
    driver.quit()
