import express from "express";
import pool from "./config/db.js";
import medidorRoutes from "./routes/medidorRoutes.js";
import inversorRoutes from "./routes/inversorRoutes.js";
import previsaoProducaoRoutes from "./routes/previsaoProducaoRoutes.js";
import producaoRoutes from "./routes/producaoRoutes.js";

const app = express();
app.use(express.json()); // ✅ Garante que o servidor entenda JSON no body

// ✅ Registra as rotas do serviço "crud-dados"
app.use("/medidor-json", medidorRoutes);
app.use("/inversor-json", inversorRoutes);
app.use("/previsao-producao", previsaoProducaoRoutes);  // 🔥 Nova rota adicionada
app.use("/producao-real", producaoRoutes);  // 🔥 Nova rota adicionada

// Testar conexão com o banco ao iniciar
const testarConexaoBanco = async () => {
    try {
        const connection = await pool.getConnection();
        await connection.ping();
        connection.release();
        console.log("✅ [crud-dados] Conexão com o banco bem-sucedida!");
    } catch (error) {
        console.error("⚠️ [crud-dados] Erro ao conectar ao banco:", error.message);
    }
};

testarConexaoBanco();

export default app;
