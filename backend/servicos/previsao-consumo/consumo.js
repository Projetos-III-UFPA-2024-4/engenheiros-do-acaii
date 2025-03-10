import puppeteer from "puppeteer";
import fs from "fs";

const CPF = "05795503207";
const DATA_NASCIMENTO = "16/05/2002";
const VALOR_CONTA_CONTRATO = "003025802461|2001090392";
const URL_SITE = "https://pa.equatorialenergia.com.br/sua-conta/historico-de-consumo/";
const CAMINHO_CSV = "C:/david/engenheiros-do-acaii/backend/servicos/previsao-consumo/dados_grafico.csv";
const MODO_VISIVEL = true;

// Função para esperar elementos na tela ou até que sumam
async function esperarElemento(page, selector, descricao, desaparecer = false) {
    console.log(`⏳ Aguardando ${descricao}...`);
    
    while (true) {
        const elemento = await page.$(selector);
        if ((elemento && !desaparecer) || (!elemento && desaparecer)) {
            console.log(`✅ ${descricao} ${desaparecer ? "removido" : "encontrado"}.`);
            return;
        }
        await page.waitForTimeout(500); // Pequena pausa para reavaliar
    }
}

async function executarAutomacao() {
    const browser = await puppeteer.launch({ headless: !MODO_VISIVEL, defaultViewport: null });
    const page = await browser.newPage();

    try {
        // 1. ACESSAR O SITE
        console.log("🌐 Acessando o site...");
        await page.goto(URL_SITE, { waitUntil: "networkidle2" });

        // 2. ESPERAR A TELA DE BLOQUEIO E REMOVÊ-LA
        console.log("⏳ Verificando se há uma tela de bloqueio...");
        await esperarElemento(page, ".tela-bloqueio", "Tela de Bloqueio", true);

        // 3. INSERIR CPF
        await esperarElemento(page, "#login-box-form-otp #identificador-otp", "Campo CPF");
        await page.type("#login-box-form-otp #identificador-otp", CPF, { delay: 100 });
        await page.keyboard.press("Tab");
        console.log("✅ CPF inserido.");

        // 4. CLICAR NO PRIMEIRO BOTÃO "ENTRAR"
        await esperarElemento(page, "#login-box-form-otp #envia-identificador-otp", "Primeiro botão Entrar");
        await page.click("#login-box-form-otp #envia-identificador-otp");
        console.log("✅ Primeiro botão 'Entrar' clicado.");

        // 5. INSERIR DATA DE NASCIMENTO
        await esperarElemento(page, "#login-box-form #senha-identificador", "Campo Data de Nascimento");

        await page.evaluate(() => {
            document.querySelector("#senha-identificador").value = "";
        });

        for (const char of DATA_NASCIMENTO) {
            await page.type("#senha-identificador", char, { delay: 100 });
        }

        await page.evaluate(() => {
            let campo = document.querySelector("#senha-identificador");
            campo.dispatchEvent(new Event("change", { bubbles: true }));
        });

        await page.keyboard.press("Tab");
        console.log("✅ Data de nascimento inserida corretamente.");

        // 6. CLICAR NO SEGUNDO BOTÃO "ENTRAR"
        await esperarElemento(page, "#login-box-form #envia-identificador", "Segundo botão Entrar");
        await page.click("#login-box-form #envia-identificador");
        console.log("✅ Segundo botão 'Entrar' clicado.");

        // 7. SELECIONAR A CONTA CONTRATO PELO VALOR
        await esperarElemento(page, ".select-wrap #conta_contrato", "Lista de Contas Contrato");
        await page.select("#conta_contrato", VALOR_CONTA_CONTRATO);
        console.log(`✅ Conta contrato selecionada: ${VALOR_CONTA_CONTRATO}`);

        // 8. EXTRAIR DADOS DO GRÁFICO
        await esperarElemento(page, ".chart-historic canvas", "Gráfico de Histórico de Consumo");

        console.log("📊 Extraindo dados do gráfico...");
        const dadosGrafico = await page.evaluate(() => {
            let labels = [];
            let valores = [];

            let chart = Chart.instances[0]; // Captura o primeiro gráfico na página
            if (chart) {
                labels = chart.data.labels;
                valores = chart.data.datasets[0].data;
            }

            return labels.map((mes, index) => ({
                mes,
                consumo: valores[index]
            }));
        });

        if (dadosGrafico.length === 0) {
            console.log("❌ Erro: Nenhum dado foi extraído do gráfico.");
            return;
        }

        console.log("✅ Dados do gráfico extraídos com sucesso.");

        // 9. SALVAR DADOS EM CSV
        console.log("📂 Salvando dados no arquivo CSV...");
        let csvContent = "Mês,Consumo\n";
        dadosGrafico.forEach(dado => {
            csvContent += `${dado.mes},${dado.consumo}\n`;
        });

        fs.writeFileSync(CAMINHO_CSV, csvContent, "utf-8");
        console.log(`✅ Arquivo CSV salvo com sucesso em: ${CAMINHO_CSV}`);

    } finally {
        if (MODO_VISIVEL) {
            console.log("Pressione Enter para fechar o navegador...");
            await new Promise(resolve => process.stdin.once("data", resolve));
        }
        await browser.close();
    }
}

executarAutomacao();
