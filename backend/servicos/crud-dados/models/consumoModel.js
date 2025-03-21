import pool from "../config/db.js";

const ConsumoModel = {
    async getUltimoMesConsumo() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM medicao_consumo"
            );
            
            if (!latestDate[0].ultimo_dia) {
                console.log("Nenhuma data disponível na tabela medicao_consumo.");
                return { ultimo_dia: null, registros: [] };
            }
            
            const ultimoDia = latestDate[0].ultimo_dia;
            
            const [rows] = await pool.query(
                "SELECT `consumoTotal`, `timestamp` FROM medicao_consumo WHERE MONTH(timestamp) = MONTH(?) AND YEAR(timestamp) = YEAR(?) ORDER BY timestamp DESC",
                [ultimoDia, ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar consumo mensal:", error);
            throw error;
        }
    },

    async getConsumoDiario() {
        try {
            const [rows] = await pool.query(
                "SELECT `consumoTotal`, `timestamp` FROM medicao_consumo ORDER BY timestamp DESC"
            );
            
            // Retorna todos os dados do consumo diário sem somar
            return { ultimo_dia: rows[0]?.timestamp, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar consumo diário:", error);
            throw error;
        }
    },

    async getConsumoSemanal() {
        try {
            // Aqui é necessário uma consulta que pega os dados da última semana
            const [rows] = await pool.query(
                "SELECT `consumoTotal`, `timestamp` FROM medicao_consumo WHERE timestamp >= CURDATE() - INTERVAL 7 DAY ORDER BY timestamp DESC"
            );
            
            return { ultimo_dia: rows[0]?.timestamp, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar consumo semanal:", error);
            throw error;
        }
    },

    async getConsumoMensal() {
        try {
            // Consulta para pegar o consumo do último mês
            const [rows] = await pool.query(
                "SELECT `consumoTotal`, `timestamp` FROM medicao_consumo WHERE MONTH(timestamp) = MONTH(CURDATE()) AND YEAR(timestamp) = YEAR(CURDATE()) ORDER BY timestamp DESC"
            );
            
            return { ultimo_dia: rows[0]?.timestamp, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar consumo mensal:", error);
            throw error;
        }
    }
};

export default ConsumoModel;
