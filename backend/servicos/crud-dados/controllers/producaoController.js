// controllers/producaoController.js
import ProducaoModel from "../models/producaoModel.js";

const ProducaoController = {
    async getProducaoReal(req, res) {
        try {
            // Busca os dados do model
            const { ultimo_dia, registros } = await ProducaoModel.getUltimoMesProducao();
            
            // Verifica se os dados estão vazios
            if (!ultimo_dia || registros.length === 0) {
                return res.status(404).json({ message: "Nenhum dado encontrado" });
            }
            
            // Somar todas as linhas da coluna "energia_solar_kw"
            const totalProducao = registros.reduce((sum, row) => {
                const energia = parseFloat(row["energia_solar_kw"]);
                return isNaN(energia) ? sum : sum + energia;
            }, 0);
            
            //console.log("Energia total produzida (kW):", totalProducao);
            //console.log("Última data registrada (vinda do model):", ultimo_dia);
            
            // Retorna os dados no JSON
            res.json({ 
                total_geracao_mes: totalProducao, 
                data_mais_recente: ultimo_dia 
            });
        } catch (error) {
            console.error("Erro no controller ao buscar produção real:", error);
            res.status(500).json({ message: "Erro interno do servidor" });
        }
    }
};

export default ProducaoController;