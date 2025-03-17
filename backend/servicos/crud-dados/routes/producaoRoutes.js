import express from 'express';
import ProducaoController from '../controllers/producaoController.js';

const router = express.Router();

// Rota para obter dados reais de produção de energia solar
router.get('/', ProducaoController.getProducaoReal);

// Rota para registrar uma nova produção real
//router.post('/', ProducaoController.createProducaoReal);

//curl -X GET http://localhost:5000/servicos/crud-dados/previsao-producao
//curl -X GET http://localhost:5000/servicos/crud-dados/producao-real

export default router;
