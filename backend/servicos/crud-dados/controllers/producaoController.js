// controllers/producaoController.js
import ProducaoModel from "../models/producaoModel.js";

const ProducaoController = {
    async getProducaoReal(req, res) {
        try {
            const { periodo } = req.query; // Parâmetro de filtro (diário, semanal, mensal)
            let dadosProducao;
            
            switch (periodo) {
                case 'diario':
                    dadosProducao = await ProducaoModel.getProducaoDiaria();
                    break;
                case 'semanal':
                    dadosProducao = await ProducaoModel.getProducaoSemanal();
                    break;
                case 'mensal':
                    dadosProducao = await ProducaoModel.getProducaoMensal();
                    break;
                case 'recente':
                default:
                    dadosProducao = await ProducaoModel.getUltimoMesProducao();
                    break;
            }

            // Verifica se os dados estão vazios
            if (!dadosProducao || dadosProducao.registros.length === 0) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }

            // Retorna os dados no formato JSON
            res.json({ 
                ultimo_dia: dadosProducao.ultimo_dia, 
                registros: dadosProducao.registros
            });
        } catch (error) {
            console.error("Erro no controller ao buscar produção real:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default ProducaoController;
