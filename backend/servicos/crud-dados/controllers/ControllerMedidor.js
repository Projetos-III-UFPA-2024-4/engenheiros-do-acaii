import { inserirDados } from '../models/medidorModel.js';

export const receberJson = async (req, res) => {
    try {
        const jsonData = req.body; // ✅ Recebe qualquer JSON enviado no corpo da requisição

        console.log(`📥 [controllerMedidor] Recebendo JSON com ${jsonData.length} registros.`);

        // 📌 Chama o model para inserir os dados no banco
        const resultado = await inserirDados(jsonData);

        if (resultado.success) {
            console.log(`✅ [controllerMedidor] JSON inserido com sucesso no banco.`);
            return res.status(200).json({ message: "Dados inseridos com sucesso!" });
        } else {
            console.error(`❌ [controllerMedidor] Erro ao inserir JSON no banco:`, resultado.error);
            return res.status(500).json({ error: "Erro ao inserir dados no banco." });
        }
    } catch (error) {
        console.error(`❌ [controllerMedidor] Erro ao processar JSON recebido:`, error.message);
        return res.status(500).json({ error: "Erro ao processar JSON recebido." });
    }
};
