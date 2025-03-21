import ConsumoModel from "../models/consumoModel.js";

const ConsumoController = {
    async getConsumoReal(req, res) {
        try {
            const { periodo } = req.query; // Parâmetro que define o tipo de consulta (diário, semanal, mensal, recente)
            
            let dadosConsumo;
            
            switch (periodo) {
                case 'diario':
                    dadosConsumo = await ConsumoModel.getConsumoDiario();
                    break;
                case 'semanal':
                    dadosConsumo = await ConsumoModel.getConsumoSemanal();
                    break;
                case 'mensal':
                    dadosConsumo = await ConsumoModel.getConsumoMensal();
                    break;
                case 'recente':
                default:
                    dadosConsumo = await ConsumoModel.getUltimoMesConsumo();
                    break;
            }

            // Verifica se os dados estão vazios
            if (!dadosConsumo || dadosConsumo.registros.length === 0) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }
            
            // Retorna os dados no formato JSON, sem somar
            res.json({ 
                ultimo_dia: dadosConsumo.ultimo_dia, 
                registros: dadosConsumo.registros 
            });
        } catch (error) {
            console.error("Erro no controller ao buscar consumo real:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default ConsumoController;
