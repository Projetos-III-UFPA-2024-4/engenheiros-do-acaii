import moment from 'moment-timezone';
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

            // Converte os horários dos registros de UTC para o horário de Brasília
            dadosConsumo.registros = dadosConsumo.registros.map(registro => {
                // Converte o tempo de UTC para o horário de Brasília
                const tempoBrasilia = moment(registro.timestamp).tz('America/Sao_Paulo', true).format('YYYY-MM-DD HH:mm:ss');
                
                return {
                    ...registro,
                    timestamp: tempoBrasilia // Substituindo pelo tempo ajustado para Brasília
                };
            });

            // Retorna os dados no formato JSON
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
