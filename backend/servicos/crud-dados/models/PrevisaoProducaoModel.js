import pool from "../config/db.js";

const PrevisaoProducaoModel = {
    async getUltimoMesPrevisao() {
        try {
            // Buscar o último mês disponível no banco
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM previsao_producao"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return [];
            }
            
            // Buscar todos os registros do último mês disponível
            const [rows] = await pool.query(
                "SELECT `geracao (kwh)`, `timestamp` FROM previsao_producao WHERE MONTH(timestamp) = MONTH(?) AND YEAR(timestamp) = YEAR(?)",
                [latestDate[0].ultimo_dia, latestDate[0].ultimo_dia]
            );
            
            return rows;
        } catch (error) {
            console.error("Erro ao buscar previsões de produção:", error);
            throw error;
        }
    }
};

export default PrevisaoProducaoModel;
