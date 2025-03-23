import express from 'express';
import ConsumoController from '../controllers/consumoController.js';

const router = express.Router();

// Rota para obter dados reais de produção de energia solar
router.get('/', ConsumoController.getConsumoReal);

// Rota para registrar uma nova produção real
//router.post('/', ConsumoController.createConsumoReal);

//curl -X GET http://localhost:5000/servicos/crud-dados/previsao-consumo
//curl -X GET http://localhost:5000/servicos/crud-dados/consumo-real

export default router;
