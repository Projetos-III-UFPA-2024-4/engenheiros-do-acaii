import puppeteer from "puppeteer";

const CPF = "05795503207"; // CPF sem pontos ou traços
const DATA_NASCIMENTO = "16/05/2002"; // Data de nascimento COM BARRAS
const URL_SITE = "https://pa.equatorialenergia.com.br/sua-conta/historico-de-consumo/";

(async () => {
    const browser = await puppeteer.launch({ headless: false, defaultViewport: null });
    const page = await browser.newPage();

    try {
        console.log("🌐 Acessando o site...");
        await page.goto(URL_SITE, { waitUntil: "networkidle2" });

        // 1. FECHAR POP-UP (Clique em "CONTINUAR NO SITE")
        try {
            await page.waitForSelector(".btn-default", { visible: true, timeout: 5000 });
            await page.click(".btn-default");
            console.log("✅ Pop-up fechado.");
        } catch {
            console.log("⚠️ Nenhum pop-up encontrado.");
        }

        // 2. INSERIR CPF
        await page.waitForSelector("#identificador-otp", { visible: true });
        await page.type("#identificador-otp", CPF, { delay: 100 });
        console.log("✅ CPF inserido.");

        // 3. CLICAR NO PRIMEIRO BOTÃO "ENTRAR"
        await page.waitForSelector("#envia-identificador-otp", { visible: true });
        await page.click("#envia-identificador-otp");
        console.log("✅ Primeiro botão 'Entrar' clicado.");

        // 4. INSERIR DATA DE NASCIMENTO
        await page.waitForSelector("#senha-identificador", { visible: true });
        await page.type("#senha-identificador", DATA_NASCIMENTO, { delay: 100 });
        console.log("✅ Data de nascimento inserida.");

        // 5. CLICAR NO SEGUNDO BOTÃO "ENTRAR"
        await page.waitForSelector("#envia-identificador", { visible: true });
        await page.click("#envia-identificador");
        console.log("✅ Segundo botão 'Entrar' clicado.");

        // 6. AGUARDAR A SELEÇÃO DA CONTA CONTRATO
        console.log("⏳ Aguardando a exibição da conta contrato...");
        await page.waitForSelector("#conta_contrato", { visible: true, timeout: 30000 });

        // 7. SELECIONAR A SEGUNDA CONTA (SE EXISTIR)
        const contas = await page.$$("#conta_contrato option");
        if (contas.length > 1) {
            await page.select("#conta_contrato", contas[1].value);
            console.log("✅ Segunda conta contrato selecionada.");
        } else {
            console.log("⚠️ Apenas uma conta contrato disponível.");
        }

        // 8. AGUARDAR O GRÁFICO CARREGAR
        console.log("⏳ Aguardando o carregamento do gráfico...");
        await page.waitForSelector("canvas", { visible: true, timeout: 15000 });

        // 9. EXTRAIR DADOS DO GRÁFICO
        const dados = await page.evaluate(() => {
            const chart = Chart.instances[0]; 
            return {
                labels: chart.data.labels,
                datasets: chart.data.datasets.map(ds => ({
                    label: ds.label,
                    data: ds.data
                }))
            };
        });

        // 10. SALVAR DADOS EM CSV
        const fs = await import("fs");
        let csvContent = "Mês," + dados.datasets.map(ds => ds.label).join(",") + "\n";
        dados.labels.forEach((label, i) => {
            csvContent += label + "," + dados.datasets.map(ds => ds.data[i]).join(",") + "\n";
        });

        fs.writeFileSync("previsao_consumo.csv", csvContent);
        console.log("✅ Dados extraídos e salvos em 'previsao_consumo.csv'.");

    } catch (error) {
        console.error("❌ Erro durante a automação:", error);
    } finally {
        await browser.close();
    }
})();
