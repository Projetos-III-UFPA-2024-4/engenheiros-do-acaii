import moment from 'moment-timezone';
import PrevisaoProducaoModel from "../models/previsaoProducaoModel.js";

const PrevisaoProducaoController = {
    async getPrevisaoProducao(req, res) {
        try {
            const { periodo } = req.query; // Parâmetro de filtro (diário, semanal, mensal)
            let dadosPrevisao;
            
            switch (periodo) {
                case 'diario':
                    dadosPrevisao = await PrevisaoProducaoModel.getPrevisaoDiaria();
                    break;
                case 'semanal':
                    dadosPrevisao = await PrevisaoProducaoModel.getPrevisaoSemanal();
                    break;
                case 'mensal':
                    dadosPrevisao = await PrevisaoProducaoModel.getPrevisaoMensal();
                    break;
                case 'recente':
                default:
                    dadosPrevisao = await PrevisaoProducaoModel.getUltimoMesPrevisao();
                    break;
            }

            // Verifica se os dados estão vazios
            if (!dadosPrevisao || dadosPrevisao.registros.length === 0) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }

            // Converte os horários dos registros de UTC para o horário de Brasília
            dadosPrevisao.registros = dadosPrevisao.registros.map(registro => {
                // Converte o tempo de UTC para o horário de Brasília
                const tempoBrasilia = moment(registro.timestamp).tz('America/Sao_Paulo', true).format('YYYY-MM-DD HH:mm:ss');
                
                return {
                    ...registro,
                    timestamp: tempoBrasilia // Substituindo pelo tempo ajustado para Brasília
                };
            });

            // Retorna os dados no formato JSON
            res.json({ 
                ultimo_dia: dadosPrevisao.ultimo_dia, 
                registros: dadosPrevisao.registros
            });
        } catch (error) {
            console.error("Erro no controller ao buscar previsões de produção:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default PrevisaoProducaoController;
