let clients = [];  // Lista de WebSockets conectados

// Função para processar e enviar o alerta para os clientes conectados
export const receberAlerta = (req, res) => {
    const { mensagem } = req.body;

    // Enviar mensagem para todos os clientes WebSocket conectados
    clients.forEach(client => {
        client.send(mensagem);
    });

    // Retorna uma resposta de sucesso
    res.status(200).json({ status: 'Alerta enviado para os clientes WebSocket', mensagem });
};

// Função para configurar WebSocket e gerenciar os clientes conectados
export const configurarWebSocket = (wss) => {
    wss.on('connection', (ws) => {
        clients.push(ws);
        console.log('Novo cliente WebSocket conectado');
        
        // Quando o cliente envia uma mensagem (caso precise de alguma interação futura)
        ws.on('message', (message) => {
            console.log(`Mensagem recebida do cliente: ${message}`);
        });

        // Quando o cliente desconecta, remove da lista de clientes
        ws.on('close', () => {
            clients = clients.filter(client => client !== ws);
            console.log('Cliente desconectado');
        });
    });
};
