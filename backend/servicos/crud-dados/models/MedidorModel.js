import db from '../config/db.js';

/**
 * Insere os dados do medidor no MySQL com controle de horário.
 * @param {Array} dados - Array de objetos JSON já mapeados para as colunas do banco
 */
export const inserirDadosMedidor = async (dados) => {
    const sql = `INSERT INTO medicao_consumo (idUsuarioTeste, hora, potA, potB, potC, potTotal, 
                                               consumoA, consumoB, consumoC, consumoTotal, 
                                               geracaoA, geracaoB, geracaoC, geracaoTotal, 
                                               iarms, ibrms, icrms, uarms, ubrms, ucrms) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
//Coluna de timestamp do banco rodando com o horario do servidor!
    try {
        const connection = await db.getConnection();
        await connection.beginTransaction(); // Inicia transação para inserir múltiplos dados

        for (const dado of dados) {
            // ✅ O controller já converteu a hora para `YYYY-MM-DD HH:MM:SS`
            if (!dado.hora) {
                console.warn("⚠️ Dados de horário ausentes! Pulando inserção deste registro:", dado);
                continue;
            }

            // ✅ Mapeia os campos do JSON para colunas no banco
            const valores = [
                dado.idUsuarioTeste, // ID do usuário teste (padrão 11)
                dado.hora, // Data e hora já formatadas pelo controller
                dado.potA || null,
                dado.potB || null,
                dado.potC || null,
                dado.potTotal || null,
                dado.consumoA || null,
                dado.consumoB || null,
                dado.consumoC || null,
                dado.consumoTotal || null,
                dado.geracaoA || null,
                dado.geracaoB || null,
                dado.geracaoC || null,
                dado.geracaoTotal || null,
                dado.iarms || null,
                dado.ibrms || null,
                dado.icrms || null,
                dado.uarms || null,
                dado.ubrms || null,
                dado.ucrms || null
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
