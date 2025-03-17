import { inserirDadosMedidor } from '../models/medidorModel.js';

/**
 * Controlador para receber os dados do medidor e inseri-los no banco de dados.
 */
export const receberDadosMedidor = async (req, res) => {
    try {
        let dados = req.body;

        // 🚀 Se os dados forem um array, converte para o formato esperado
        if (Array.isArray(dados)) {
            console.warn("⚠️ JSON recebido como array, convertendo para 'dataList'...");
            dados = { dataList: dados.flatMap(item => 
                Object.entries(item).map(([key, value]) => ({ key, value }))
            )};
        }

        // 🚀 Validações do JSON antes de processar
        if (!dados || typeof dados !== 'object' || Object.keys(dados).length === 0) {
            return res.status(400).json({ success: false, message: "JSON inválido ou vazio!" });
        }

        if (!dados.dataList || !Array.isArray(dados.dataList) || dados.dataList.length === 0) {
            return res.status(400).json({ success: false, message: "JSON deve conter um array 'dataList'!" });
        }

        // 🔹 Mapeamento das chaves do JSON para os nomes das colunas no banco
        const mapeamento = {
            "pa": "potA",
            "pb": "potB",
            "pc": "potC",
            "pt": "potTotal",
            "epa_c": "consumoA",
            "epb_c": "consumoB",
            "epc_c": "consumoC",
            "ept_c": "consumoTotal",
            "epa_g": "geracaoA",
            "epb_g": "geracaoB",
            "epc_g": "geracaoC",
            "ept_g": "geracaoTotal",
            "iarms": "iarms",
            "ibrms": "ibrms",
            "icrms": "icrms",
            "uarms": "uarms",
            "ubrms": "ubrms",
            "ucrms": "ucrms",
            "hora": "hora",
            "minuto": "minuto",
            "segundo": "segundo"
        };

        // 🔹 Converte a estrutura do JSON para o formato correto
        const dadosFormatados = {};
        dados.dataList.forEach(item => {
            if (mapeamento[item.key]) {
                dadosFormatados[mapeamento[item.key]] = item.value;
            }
        });

        // 📌 Adiciona um idUsuarioTeste fixo (se necessário)
        dadosFormatados.idUsuarioTeste = 11;

        // 🚀 Validação e conversão da hora
        if (
            dadosFormatados.hora !== undefined &&
            dadosFormatados.minuto !== undefined &&
            dadosFormatados.segundo !== undefined
        ) {
            // Converte para formato DATETIME no MySQL (YYYY-MM-DD HH:MM:SS)
            dadosFormatados.hora = `${new Date().toISOString().slice(0, 10)} ${dadosFormatados.hora}:${dadosFormatados.minuto}:${dadosFormatados.segundo}`;
        } else {
            return res.status(400).json({ success: false, message: "Dados de horário incompletos!" });
        }

        // 📌 Remove os campos 'minuto' e 'segundo' após a conversão
        delete dadosFormatados.minuto;
        delete dadosFormatados.segundo;

        // 📌 Chama o Model para salvar no banco de dados
        const resultado = await inserirDadosMedidor([dadosFormatados]); // Passando um array, pois o model espera múltiplos registros

        if (resultado.success) {
            console.log(`✅ JSON inserido com sucesso no banco.`);
            return res.status(200).json({ message: "Dados inseridos com sucesso!" });
        } else {
            console.error(`❌ Erro ao inserir JSON no banco:`, resultado.error);
            return res.status(500).json({ error: "Erro ao inserir dados no banco." });
        }

    } catch (error) {
        console.error(`❌ Erro ao processar JSON recebido:`, error.message);
        return res.status(500).json({ error: "Erro ao processar JSON recebido." });
    }
};
