// controllers/previsaoProducaoController.js
import PrevisaoProducaoModel from "../models/PrevisaoProducaoModel.js";

const PrevisaoProducaoController = {
    async getPrevisaoProducao(req, res) {
        try {
            const data = await PrevisaoProducaoModel.getUltimoMesPrevisao();
            
            if (!data.length) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }
            
            // Somar todas as linhas da coluna "geracao (kwh)"
            const totalGeracao = data.reduce((sum, row) => sum + row["geracao (kwh)"], 0);
            
            // Pegar a data mais recente corretamente
            const dataMaisRecente = data.reduce((max, row) => new Date(row.timestamp) > new Date(max) ? row.timestamp : max, data[0].timestamp);
            
            res.json({ "total_geracao_prevista_mes": totalGeracao, "data_mais_recente": dataMaisRecente });
        } catch (error) {
            console.error("Erro ao buscar previsões de produção:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default PrevisaoProducaoController;
