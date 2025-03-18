import pool from "../config/db.js";

const PrevisaoConsumoModel = {
    async getUltimoMesPrevisao() {
        try {
            // Buscar o último mês disponível no banco
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM previsao_consumo"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return [];
            }
            
            // Buscar todos os registros do último mês disponível
            const [rows] = await pool.query(
                "SELECT `consumo`, `timestamp` FROM previsao_consumo WHERE MONTH(timestamp) = MONTH(?) AND YEAR(timestamp) = YEAR(?)",
                [latestDate[0].ultimo_dia, latestDate[0].ultimo_dia]
            );
            
            return rows;
        } catch (error) {
            console.error("Erro ao buscar previsões de consumo:", error);
            throw error;
        }
    }
};

export default PrevisaoConsumoModel;
