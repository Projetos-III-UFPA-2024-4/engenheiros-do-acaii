// models/previsaoConsumoModel.js
import pool from "../config/db.js";

const PrevisaoConsumoModel = {
    // Pega os dados do último mês registrado
    async getUltimoMesPrevisao() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM previsao_consumo"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return { ultimo_dia: null, registros: [] };
            }
            
            const ultimoDia = latestDate[0].ultimo_dia;
            
            const [rows] = await pool.query(
                "SELECT `consumo`, `timestamp` FROM previsao_consumo WHERE DATE(timestamp) = ? ORDER BY timestamp DESC",
                [ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar previsões de consumo:", error);
            throw error;
        }
    },

    // Pega os dados do último dia registrado
    async getPrevisaoDiaria() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM previsao_consumo"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return { ultimo_dia: null, registros: [] };
            }

            const ultimoDia = latestDate[0].ultimo_dia;

            const [rows] = await pool.query(
                "SELECT `consumo`, `timestamp` FROM previsao_consumo WHERE DATE(timestamp) = ? ORDER BY timestamp DESC",
                [ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar previsões diárias de consumo:", error);
            throw error;
        }
    },

    // Pega os dados dos últimos 7 dias registrados
    async getPrevisaoSemanal() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM previsao_consumo"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return { ultimo_dia: null, registros: [] };
            }

            const ultimoDia = latestDate[0].ultimo_dia;

            const [rows] = await pool.query(
                "SELECT `consumo`, `timestamp` FROM previsao_consumo " +
                "WHERE timestamp >= DATE_SUB(?, INTERVAL 7 DAY) AND DATE(timestamp) <= ? " +
                "ORDER BY timestamp DESC",
                [ultimoDia, ultimoDia]
            );

            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar previsões semanais de consumo:", error);
            throw error;
        }
    },

    // Pega os dados do mês mais recente registrado
    async getPrevisaoMensal() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_mes FROM previsao_consumo"
            );
            
            if (!latestDate[0].ultimo_mes) {
                return { ultimo_dia: null, registros: [] };
            }

            const ultimoMes = latestDate[0].ultimo_mes;

            const [rows] = await pool.query(
                "SELECT `consumo`, `timestamp` FROM previsao_consumo WHERE MONTH(timestamp) = MONTH(?) AND YEAR(timestamp) = YEAR(?) ORDER BY timestamp DESC",
                [ultimoMes, ultimoMes]
            );
            
            return { ultimo_dia: ultimoMes, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar previsões mensais de consumo:", error);
            throw error;
        }
    }
};

export default PrevisaoConsumoModel;
