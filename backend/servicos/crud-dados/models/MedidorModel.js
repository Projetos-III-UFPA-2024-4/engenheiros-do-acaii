import db from '../config/db.js';

/**
 * Insere os dados do medidor no MySQL com controle de horário.
 * @param {Array} dados - Array de objetos JSON já mapeados para as colunas do banco
 */
export const inserirDadosMedidor = async (dados) => {
    const sql = `INSERT INTO medicao_consumo (timestamp, potA, potB, potC, potTotal, 
                                               consumoTotal) 
                 VALUES (?, ?, ?, ?, ?, ?)`;

    try {
        const connection = await db.getConnection();
        await connection.beginTransaction(); // Inicia transação para inserir múltiplos dados

        for (const dado of dados) {
            // ✅ O controller já converteu o timestamp para `YYYY-MM-DD HH:MM:SS`
            if (!dado.timestamp) {
                console.warn("⚠️ Dados de horário ausentes! Pulando inserção deste registro:", dado);
                continue;
            }

            // ✅ Mapeia os campos do JSON para colunas no banco
            const valores = [
                dado.timestamp,            // Data e hora já formatadas pelo controller
                dado.potA || null,
                dado.potB || null,
                dado.potC || null,
                dado.potTotal || null,
                dado.consumoTotal || null
            ];

            await connection.execute(sql, valores);
        }

        await connection.commit(); // Confirma a transação
        connection.release(); // Libera a conexão

        console.log("✅ Dados do medidor inseridos com sucesso!");
        return { success: true };

    } catch (error) {
        console.error("❌ Erro ao inserir dados do medidor no banco:", error);
        return { success: false, error };
    }
};
