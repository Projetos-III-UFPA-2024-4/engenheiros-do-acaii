import db from '../config/db.js';

/**
 * Insere os dados do inversor no MySQL com nomes de colunas descritivos.
 * @param {Array} dados - Array de objetos JSON já mapeados para as colunas do banco
 */
export const inserirDadosInversor = async (dados) => {
    const sql = `INSERT INTO medicao_producao (idUsuarioTeste, tensao_pv1, corrente_pv1, potencia_pv1, 
                                               tensao_rede_l1, corrente_rede_l1, potencia_rede_l1, 
                                               tensao_bateria, corrente_bateria, potencia_bateria, 
                                               status_rede, status_bateria, status_rele_rede) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    try {
        const connection = await db.getConnection();
        await connection.beginTransaction(); // Inicia transação para inserir múltiplos dados

        for (const dado of dados) {
            const valores = [
                dado.idUsuarioTeste, // ID do usuário teste (padrão 11)
                dado.tensao_pv1 || null,
                dado.corrente_pv1 || null,
                dado.potencia_pv1 || null,
                dado.tensao_rede_l1 || null,
                dado.corrente_rede_l1 || null,
                dado.potencia_rede_l1 || null,
                dado.tensao_bateria || null,
                dado.corrente_bateria || null,
                dado.potencia_bateria || null,
                dado.status_rede || null,
                dado.status_bateria || null,
                dado.status_rele_rede || null
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
