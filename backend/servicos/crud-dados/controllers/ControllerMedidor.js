import fs from 'fs/promises';
import path from 'path';
import { inserirDados } from '../models/medidorModel.js';

export const inserirDadosArquivo = async (req, res) => {
    const caminhoArquivo = path.resolve('servicos/crud-dados/controllers', 'testeDados1.json'); // ✅ Caminho correto

    try {
        console.log(`📂 [controllerMedidor] Lendo o arquivo JSON: ${caminhoArquivo}`);

        // 📌 Ler o arquivo JSON
        const data = await fs.readFile(caminhoArquivo, 'utf8');
        const jsonData = JSON.parse(data);

        console.log(`📊 [controllerMedidor] JSON carregado com ${jsonData.length} registros.`);

        // 📌 Tentar inserir os dados no banco
        const resultado = await inserirDados(jsonData);

        if (resultado.success) {
            console.log(`✅ [controllerMedidor] Dados de 'testeDados1.json' inseridos com sucesso no banco.`);
            return res.status(200).json({ message: "Dados inseridos com sucesso!" });
        } else {
            console.error(`❌ [controllerMedidor] Erro ao inserir 'testeDados1.json' no banco:`, resultado.error);
            return res.status(500).json({ error: "Erro ao inserir dados no banco." });
        }
    } catch (error) {
        console.error(`❌ [controllerMedidor] Erro ao processar o arquivo 'testeDados1.json':`, error.message);
        return res.status(500).json({ error: "Erro ao processar JSON ou acessar arquivo." });
    }
};
