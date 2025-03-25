import { inserirDadosInversor } from '../models/inversorModel.js';

/**
 * Controlador para receber os dados do inversor e inseri-los no banco de dados.
 */
export const receberDadosInversor = async (req, res) => {
    try {
        let dados = req.body;

        // 🚀 Validações do JSON antes de processar
        if (!dados || !Array.isArray(dados) || dados.length === 0) {
            return res.status(400).json({ success: false, message: "JSON inválido ou vazio!" });
        }

        // 🔹 Mapeamento das chaves do JSON para os nomes das colunas no banco
        const mapeamento = {
            "tempo": "tempo",  // Usando 'tempo' diretamente para corresponder ao nome do campo
            "energia_solar_kw": "energia_solar_kw", 
            "clima": "clima",
            "feed_in_kw": "feed_in_kw",
            "compra_kw": "compra_kw"
        };

        // 🔹 Converte a estrutura do JSON para o formato correto
        const dadosFormatados = dados.map(item => {
            const itemFormatado = {};
            Object.entries(item).forEach(([key, value]) => {
                if (mapeamento[key]) {
                    itemFormatado[mapeamento[key]] = value;
                }
            });

            return itemFormatado;
        });

        // 📌 Chama o Model para salvar no banco de dados
        const resultado = await inserirDadosInversor(dadosFormatados);

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
