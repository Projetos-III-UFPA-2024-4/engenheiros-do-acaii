import connection from '../config/db.js';

export const inserirDados = async (dados) => {
    const sql = `INSERT INTO medicao_consumo (hora, potA, potB, potC, potTotal, consumoA, consumoB, consumoC, consumoTotal, 
                                               geracaoA, geracaoB, geracaoC, geracaoTotal, iarms, ibrms, icrms, uarms, ubrms, ucrms) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    try {
        for (const dado of dados) {
            // ✅ Converte os valores de hora, minuto e segundo para um formato DATETIME (YYYY-MM-DD HH:MM:SS)
            const dataHoraFormatada = new Date();
            dataHoraFormatada.setHours(dado.hora);
            dataHoraFormatada.setMinutes(dado.minuto);
            dataHoraFormatada.setSeconds(dado.segundo);

            // ✅ Mapeia os nomes antigos do JSON para os novos nomes no banco
            const valores = [
                dataHoraFormatada.toISOString().slice(0, 19).replace('T', ' '), // Formata para DATETIME
                dado.pa, dado.pb, dado.pc, dado.pt,   // potA, potB, potC, potTotal
                dado.epa_c, dado.epb_c, dado.epc_c, dado.ept_c, // consumoA, consumoB, consumoC, consumoTotal
                dado.epa_g, dado.epb_g, dado.epc_g, dado.ept_g, // geracaoA, geracaoB, geracaoC, geracaoTotal
                dado.iarms, dado.ibrms, dado.icrms, dado.uarms, dado.ubrms, dado.ucrms
            ];

            await connection.execute(sql, valores);
        }
        return { success: true };
    } catch (error) {
        console.error("❌ Erro ao inserir dados no banco:", error);
        return { success: false, error };
    }
};
