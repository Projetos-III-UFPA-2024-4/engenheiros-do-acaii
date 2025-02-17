import express from "express";
import pool from "../config/db.js";

const router = express.Router();

// Rota para testar a conexão com o banco
router.get("/teste-conexao", async (req, res) => {
    try {
        const connection = await pool.getConnection();
        await connection.ping(); // Testa a conexão com o banco
        connection.release();
        res.status(200).json({ success: true, message: "Conexão com o banco bem-sucedida!" });
    } catch (error) {
        res.status(500).json({ success: false, message: "Erro ao conectar ao banco!", error: error.message });
    }
});

export default router;
