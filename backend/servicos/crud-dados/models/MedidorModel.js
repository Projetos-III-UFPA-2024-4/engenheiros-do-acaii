import connection from '../config/db.js';

export const inserirDados = async (dados) => {
    const sql = `INSERT INTO medicao_consumo (hora, minuto, segundo, pa, pb, pc, pt, epa_c, epb_c, epc_c, ept_c, 
                                               epa_g, epb_g, epc_g, ept_g, iarms, ibrms, icrms, uarms, ubrms, ucrms) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    try {
        for (const dado of dados) {
            const valores = [
                dado.hora, dado.minuto, dado.segundo, dado.pa, dado.pb, dado.pc, dado.pt,
                dado.epa_c, dado.epb_c, dado.epc_c, dado.ept_c, dado.epa_g, dado.epb_g,
                dado.epc_g, dado.ept_g, dado.iarms, dado.ibrms, dado.icrms, dado.uarms,
                dado.ubrms, dado.ucrms
            ];
            await connection.execute(sql, valores);
        }
        return { success: true };
    } catch (error) {
        return { success: false, error };
    }
};
