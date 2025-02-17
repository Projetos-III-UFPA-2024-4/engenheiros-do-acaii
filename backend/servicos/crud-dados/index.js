import express from "express";
import pool from "./config/db.js";
import dadosRoutes from "./routes/dadosRoutes.js";

const app = express();
app.use(express.json());

// Middleware para registrar as rotas
app.use("/api/dados", dadosRoutes);

// Testar a conexão com o banco quando o serviço iniciar
const testarConexaoBanco = async () => {
    try {
        const connection = await pool.getConnection();
        await connection.ping(); // Testa a conexão
        connection.release();
        console.log("✅ [crud-dados] Conexão com o banco bem-sucedida!");
    } catch (error) {
        console.error("⚠️ [crud-dados] Erro ao conectar ao banco:", error.message);
    }
};

// Executa o teste ao carregar o serviço
testarConexaoBanco();

export default app;
