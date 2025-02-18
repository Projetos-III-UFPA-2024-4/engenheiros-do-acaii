import express from "express";
import dotenv from "dotenv";
import crudDadosService from "./servicos/crud-dados/index.js"; // Importa o serviço corretamente

dotenv.config(); // Carrega as variáveis do .env

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware para JSON
app.use(express.json());

// Registra os serviços SOA
app.use("/servico-crud-dados", crudDadosService);

// Iniciar o servidor
app.listen(PORT, () => {
    console.log(`🚀 Servidor rodando na porta ${PORT}`);
});
