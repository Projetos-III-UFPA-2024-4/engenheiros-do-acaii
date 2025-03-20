import pool from "../config/db.js";

const ConsumoModel = {
    async getUltimoMesConsumo() {
        try {
            // Buscar o último dia disponível no banco
            const [latestDate] = await pool.query(
                "SELECT MAX(DATE(timestamp)) AS ultimo_dia FROM medicao_consumo"
            );
            
            // Verifica se há dados
            if (!latestDate[0].ultimo_dia) {
                console.log("Nenhuma data disponível na tabela medicao_consumo.");
                return { ultimo_dia: null, registros: [] };
            }
            
            const ultimoDia = latestDate[0].ultimo_dia;
            //console.log("Última data disponível:", ultimoDia);
            
            // Buscar apenas registros do mesmo mês e ano do último dia encontrado
            const [rows] = await pool.query(
                "SELECT `consumoTotal`, `timestamp` FROM medicao_consumo WHERE MONTH(timestamp) = MONTH(?) AND YEAR(timestamp) = YEAR(?) ORDER BY timestamp DESC",
                [ultimoDia, ultimoDia]
            );
            
            return { ultimo_dia: ultimoDia, registros: rows };
        } catch (error) {
            console.error("Erro ao buscar produção real:", error);
            throw error;
        }
    }
};

export default ConsumoModel;