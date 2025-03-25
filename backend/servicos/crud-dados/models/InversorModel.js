import db from '../config/db.js';

/**
 * Insere os dados do inversor no MySQL com controle de horário.
 * @param {Array} dados - Array de objetos JSON já mapeados para as colunas do banco
 */
export const inserirDadosInversor = async (dados) => {
    const sql = `INSERT INTO medicao_producao (tempo, energia_solar_kw, clima, feed_in_kw, compra_kw) 
                 VALUES (?, ?, ?, ?, ?)`;

    try {
        const connection = await db.getConnection();
        await connection.beginTransaction(); // Inicia transação para inserir múltiplos dados

        for (const dado of dados) {
            // Verifica se o campo tempo está presente
            if (!dado.tempo) {
                console.warn("⚠️ Dados de horário ausentes! Pulando inserção deste registro:", dado);
                continue;
            }

            const valores = [
                dado.tempo,            // Mantendo o formato original de 'tempo'
                dado.energia_solar_kw || null,
                dado.clima || null,
                dado.feed_in_kw || null,
                dado.compra_kw || null
            ];

            await connection.execute(sql, valores);
        }

        await connection.commit(); // Confirma a transação
        connection.release(); // Libera a conexão

        console.log("✅ Dados do inversor inseridos com sucesso!");
        return { success: true };

    } catch (error) {
        console.error("❌ Erro ao inserir dados do inversor no banco:", error);
        return { success: false, error };
    }
};
