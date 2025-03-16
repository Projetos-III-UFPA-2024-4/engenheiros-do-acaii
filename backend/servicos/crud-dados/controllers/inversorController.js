import { inserirDadosInversor } from '../models/inversorModel.js';

/**
 * Controlador para receber os dados do inversor e inseri-los no banco de dados.
 */
export const receberDadosInversor = async (req, res) => {
    try {
        const dados = req.body;

        // 🚀 Validações do JSON antes de processar
        if (!dados || typeof dados !== 'object' || Object.keys(dados).length === 0) {
            return res.status(400).json({ success: false, message: "JSON inválido ou vazio!" });
        }

        if (!dados.dataList || !Array.isArray(dados.dataList) || dados.dataList.length === 0) {
            return res.status(400).json({ success: false, message: "JSON deve conter um array 'dataList'!" });
        }

        // 🔹 Mapeamento das chaves do JSON para os nomes das colunas no banco
        const mapeamento = {
            "DV1": "tensao_pv1",
            "DC1": "corrente_pv1",
            "DP1": "potencia_pv1",
            "G_V_L1": "tensao_rede_l1",
            "G_C_L1": "corrente_rede_l1",
            "G_P_L1": "potencia_rede_l1",
            "B_V1": "tensao_bateria",
            "B_C1": "corrente_bateria",
            "B_P1": "potencia_bateria",
            "ST_PG1": "status_rede",
            "B_ST1": "status_bateria",
            "GRID_RELAY_ST1": "status_rele_rede"
        };

        // 🔹 Converte a estrutura do JSON para o formato correto
        const dadosFormatados = {};
        dados.dataList.forEach(item => {
            if (mapeamento[item.key]) {
                dadosFormatados[mapeamento[item.key]] = item.value;
            }
        });

        // 📌 Adiciona um idUsuarioTeste fixo (se necessário)
        dadosFormatados.idUsuarioTeste = 11;

        // 📌 Chama o Model para salvar no banco de dados
        const resultado = await inserirDadosInversor([dadosFormatados]); // Passando um array, pois o model espera múltiplos registros

        if (resultado.success) {
            console.log(`✅ JSON inserido com sucesso no banco.`);
            return res.status(200).json({ message: "Dados inseridos com sucesso!" });
        } else {
            console.error(`❌ Erro ao inserir JSON no banco:`, resultado.error);
            return res.status(500).json({ error: "Erro ao inserir dados no banco." });
        }

    } catch (error) {
        console.error(`❌ Erro ao processar JSON recebido:`, error.message);
        return res.status(500).json({ error: "Erro ao processar JSON recebido." });
    }
};


/*
  | "DV1"        | "tensao_pv1"                 | Tensão do Painel FV1 (V) |
  | "DC1"        | "corrente_pv1"               | Corrente do Painel FV1 (A) |
  | "DP1"        | "potencia_pv1"               | Potência gerada pelo Painel FV1 (W) |
  | "G_V_L1"     | "tensao_rede_l1"             | Tensão da Rede Elétrica na Fase L1 (V) |
  | "G_C_L1"     | "corrente_rede_l1"           | Corrente da Rede Elétrica na Fase L1 (A) |
  | "G_P_L1"     | "potencia_rede_l1"           | Potência consumida/injetada na Rede na Fase L1 (W) |
  | "B_V1"       | "tensao_bateria"             | Tensão da Bateria (V) |
  | "B_C1"       | "corrente_bateria"           | Corrente da Bateria (A) |
  | "B_P1"       | "potencia_bateria"           | Potência da Bateria (W) |
  | "ST_PG1"     | "status_rede"                | Status da Conexão com a Rede ("Static", "Purchasing energy") |
  | "B_ST1"      | "status_bateria"             | Estado da Bateria ("Charging", "Discharging") |
  | "GRID_RELAY_ST1" | "status_rele_rede"      | Status do Relé de Conexão com a Rede ("Pull-in", "Pull-out") |
  ----------------------------------------------------------------------
*/