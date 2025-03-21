// models/producaoModel.js
import pool from "../config/db.js";

const ProducaoModel = {
    // Pega os dados do último mês registrado
    async getUltimoMesProducao() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(tempo)) AS ultimo_dia FROM medicao_producao"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return { ultimo_dia: null, registros: [] };
            }
            
            const ultimoDia = latestDate[0].ultimo_dia;
            
            const [rows] = await pool.query(
                "SELECT `energia_solar_kw`, `tempo` FROM medicao_producao WHERE DATE(tempo) = ? ORDER BY tempo DESC",
                [ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar produção real:", error);
            throw error;
        }
    },

    // Pega os dados do último dia registrado
    async getProducaoDiaria() {
        try {
            // Buscar o último dia disponível no banco
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(tempo)) AS ultimo_dia FROM medicao_producao"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return { ultimo_dia: null, registros: [] };
            }

            const ultimoDia = latestDate[0].ultimo_dia;

            // Buscar todos os registros do último dia disponível
            const [rows] = await pool.query(
                "SELECT `energia_solar_kw`, `tempo` FROM medicao_producao WHERE DATE(tempo) = ? ORDER BY tempo DESC",
                [ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar produção diária:", error);
            throw error;
        }
    },

    // Pega os dados dos últimos 7 dias registrados no banco, considerando hora e minuto
    async getProducaoSemanal() {
        try {
            // Encontra o último dia registrado
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(tempo)) AS ultimo_dia FROM medicao_producao"
            );
            
            if (!latestDate[0].ultimo_dia) {
                return { ultimo_dia: null, registros: [] };
            }

            const ultimoDia = latestDate[0].ultimo_dia;

            // Busca os dados dos últimos 7 dias, incluindo todos os registros (sem soma)
            const [rows] = await pool.query(
                "SELECT `energia_solar_kw`, `tempo` FROM medicao_producao " +
                "WHERE tempo >= DATE_SUB(?, INTERVAL 7 DAY) AND DATE(tempo) <= ? " +
                "ORDER BY tempo DESC",
                [ultimoDia, ultimoDia]
            );

            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar produção semanal:", error);
            throw error;
        }
    },

    // Pega os dados do mês mais recente registrado no banco
    async getProducaoMensal() {
        try {
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(tempo)) AS ultimo_mes FROM medicao_producao"
            );
            
            if (!latestDate[0].ultimo_mes) {
                return { ultimo_dia: null, registros: [] };
            }

            const ultimoMes = latestDate[0].ultimo_mes;

            const [rows] = await pool.query(
                "SELECT `energia_solar_kw`, `tempo` FROM medicao_producao WHERE MONTH(tempo) = MONTH(?) AND YEAR(tempo) = YEAR(?) ORDER BY tempo DESC",
                [ultimoMes, ultimoMes]
            );
            
            return { ultimo_dia: ultimoMes, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar produção mensal:", error);
            throw error;
        }
    }
};

export default ProducaoModel;
