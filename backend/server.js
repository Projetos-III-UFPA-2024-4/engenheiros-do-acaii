import express from "express";
import dotenv from "dotenv";
import crudDadosService from "./servicos/crud-dados/index.js"; // ✅ Importa o serviço "crud-dados"
import cors from 'cors';

dotenv.config(); // Carrega variáveis de ambiente do .env

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors()); // ✅ Habilita JSON no corpo da requisição

// ✅ Registra o serviço "crud-dados"
app.use("/servicos/crud-dados", crudDadosService);

app.listen(PORT, () => {
    console.log(`🚀 Servidor rodando na porta ${PORT}`);
});
