import puppeteer from "puppeteer";
import fs from "fs";

const CPF = "05795503207";
const DATA_NASCIMENTO = "16/05/2002";
const VALOR_CONTA_CONTRATO = "003025802461|2001090392";
const URL_SITE = "https://pa.equatorialenergia.com.br/sua-conta/historico-de-consumo/";
const CAMINHO_CSV = "C:/david/engenheiros-do-acaii/backend/servicos/previsao-consumo/dados_grafico.csv";
const MODO_VISIVEL = true;

async function executarAutomacao() {
    const browser = await puppeteer.launch({ headless: !MODO_VISIVEL, defaultViewport: null });
    const page = await browser.newPage();

    try {
        // 1. ACESSAR O SITE
        console.log("🌐 Acessando o site...");
        await page.goto(URL_SITE, { waitUntil: "networkidle2" });

        // 2. FECHAR POP-UP
        try {
            console.log("⏳ Aguardando pop-up aparecer...");
            await page.waitForSelector(".btn-default", { timeout: 15000, visible: true });
            await page.click(".btn-default");
            console.log("✅ Pop-up fechado com sucesso.");
        } catch {
            console.log("⚠️ Pop-up não encontrado a tempo! Tentando via JavaScript...");
            await page.evaluate(() => {
                let botao = document.querySelector(".btn-default");
                if (botao) botao.click();
            });
        }

        // 3. INSERIR CPF
        console.log("⏳ Preenchendo CPF...");
        await page.waitForSelector("#login-box-form-otp #identificador-otp", { timeout: 5000 });
        await page.type("#login-box-form-otp #identificador-otp", CPF, { delay: 100 });
        await page.keyboard.press("Tab");
        console.log("✅ CPF inserido corretamente.");

        // 4. CLICAR NO PRIMEIRO BOTÃO "ENTRAR"
        console.log("⏳ Clicando no primeiro botão 'Entrar'...");
        await page.click("#login-box-form-otp #envia-identificador-otp");
        console.log("✅ Primeiro botão 'Entrar' clicado.");

        // 5. INSERIR DATA DE NASCIMENTO
        console.log("⏳ Aguardando campo de data de nascimento...");
        await page.waitForSelector("#login-box-form #senha-identificador", { timeout: 5000 });
        await page.type("#login-box-form #senha-identificador", DATA_NASCIMENTO, { delay: 100 });
        await page.keyboard.press("Tab");
        console.log("✅ Data de nascimento inserida corretamente.");

        // 6. CLICAR NO SEGUNDO BOTÃO "ENTRAR"
        console.log("⏳ Clicando no segundo botão 'Entrar'...");
        await page.click("#login-box-form #envia-identificador");
        console.log("✅ Segundo botão 'Entrar' clicado.");

        // 7. SELECIONAR A CONTA CONTRATO PELO VALOR
        console.log("⏳ Aguardando a exibição da área de seleção de conta contrato...");
        await page.waitForSelector(".select-wrap #conta_contrato", { timeout: 10000 });

        console.log(`⏳ Tentando selecionar conta contrato: ${VALOR_CONTA_CONTRATO}`);
        await page.select("#conta_contrato", VALOR_CONTA_CONTRATO);
        console.log(`✅ Conta contrato selecionada pelo valor: ${VALOR_CONTA_CONTRATO}`);

        // 8. EXTRAIR DADOS DO GRÁFICO
        console.log("⏳ Aguardando carregamento do gráfico...");
        await page.waitForSelector(".chart-historic canvas", { timeout: 10000 });

        console.log("📊 Extraindo dados do gráfico...");
        const dadosGrafico = await page.evaluate(() => {
            let labels = [];
            let valores = [];

            // O site usa Chart.js para renderizar os gráficos
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
