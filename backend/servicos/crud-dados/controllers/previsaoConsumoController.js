// controllers/previsaoProducaoController.js
import PrevisaoConsumoModel from "../models/PrevisaoConsumoModel.js";

const PrevisaoConsumoController = {
    async getPrevisaoConsumo(req, res) {
        try {
            const data = await PrevisaoConsumoModel.getUltimoMesPrevisao();
            
            if (!data.length) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }
            
            // Somar todas as linhas da coluna "geracao (kwh)"
            const totalConsumo = data.reduce((sum, row) => sum + row["consumo"], 0);
            
            // Pegar a data mais recente corretamente
            const dataMaisRecente = data.reduce((max, row) => new Date(row.timestamp) > new Date(max) ? row.timestamp : max, data[0].timestamp);
            
            res.json({ "total_geracao_prevista_mes": totalConsumo, "data_mais_recente": dataMaisRecente });
        } catch (error) {
            console.error("Erro ao buscar previsões de produção:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default PrevisaoConsumoController;
