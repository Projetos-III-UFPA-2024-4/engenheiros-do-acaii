// models/producaoModel.js
import pool from "../config/db.js";

const ProducaoModel = {
    async getUltimoMesProducao() {
        try {
            // Buscar o último dia disponível no banco
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(tempo)) AS ultimo_dia FROM medicao_producao"
            );
            
            // Verifica se há dados
            if (!latestDate[0].ultimo_dia) {
                console.log("Nenhuma data disponível na tabela medicao_producao.");
                return { ultimo_dia: null, registros: [] };
            }
            
            const ultimoDia = latestDate[0].ultimo_dia;
            //console.log("Última data disponível:", ultimoDia);
            
            // Buscar apenas registros do mesmo mês e ano do último dia encontrado
            const [rows] = await pool.query(
                "SELECT `energia_solar_kw`, `tempo` FROM medicao_producao WHERE MONTH(tempo) = MONTH(?) AND YEAR(tempo) = YEAR(?) ORDER BY tempo DESC",
                [ultimoDia, ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar produção real:", error);
            throw error;
        }
    }
};

export default ProducaoModel;