// controllers/previsaoConsumoController.js
import PrevisaoConsumoModel from "../models/previsaoConsumoModel.js";

const PrevisaoConsumoController = {
    async getPrevisaoConsumo(req, res) {
        try {
            const { periodo } = req.query; // Parâmetro de filtro (diário, semanal, mensal)
            let dadosConsumo;
            
            switch (periodo) {
                case 'diario':
                    dadosConsumo = await PrevisaoConsumoModel.getPrevisaoDiaria();
                    break;
                case 'semanal':
                    dadosConsumo = await PrevisaoConsumoModel.getPrevisaoSemanal();
                    break;
                case 'mensal':
                    dadosConsumo = await PrevisaoConsumoModel.getPrevisaoMensal();
                    break;
                case 'recente':
                default:
                    dadosConsumo = await PrevisaoConsumoModel.getUltimoMesPrevisao();
                    break;
            }

            // Verifica se os dados estão vazios
            if (!dadosConsumo || dadosConsumo.registros.length === 0) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }

            // Retorna os dados no formato JSON
            res.json({ 
                ultimo_dia: dadosConsumo.ultimo_dia, 
                registros: dadosConsumo.registros
            });
        } catch (error) {
            console.error("Erro no controller ao buscar previsões de consumo:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default PrevisaoConsumoController;
