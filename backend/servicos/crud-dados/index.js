import express from "express";
import { WebSocketServer } from "ws";  // Importa a biblioteca para WebSocket
import pool from "./config/db.js";
import medidorRoutes from "./routes/medidorRoutes.js";
import inversorRoutes from "./routes/inversorRoutes.js";
import previsaoProducaoRoutes from "./routes/previsaoProducaoRoutes.js";
import producaoRoutes from "./routes/producaoRoutes.js";
import previsaoConsumoRoutes from "./routes/previsaoConsumoRoutes.js";
import consumoRoutes from "./routes/consumoRoutes.js";
import { configurarWebSocket, receberAlerta } from "./controllers/alertaController.js";

const app = express();
app.use(express.json()); // ✅ Garante que o servidor entenda JSON no body

// ✅ Registra as rotas do serviço "crud-dados"
app.use("/medidor-json", medidorRoutes);
app.use("/inversor-json", inversorRoutes);
app.use("/previsao-producao", previsaoProducaoRoutes);
app.use("/producao-real", producaoRoutes);
app.use("/previsao-consumo", previsaoConsumoRoutes);
app.use("/consumo-real", consumoRoutes);

// Rota de alerta para receber e disparar notificações WebSocket
app.post("/alerta", receberAlerta); // Chama o controller para enviar a mensagem via WebSocket

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

// Inicia a conexão com o WebSocket e configura os clientes
const server = app.listen(3001, () => {
    console.log("🚀 Servidor 'crud-dados' rodando na porta 3001");
});

// Cria o servidor WebSocket
const wss = new WebSocketServer({ server });

// Configura os WebSockets para este serviço
configurarWebSocket(wss);

testarConexaoBanco();

export default app;
