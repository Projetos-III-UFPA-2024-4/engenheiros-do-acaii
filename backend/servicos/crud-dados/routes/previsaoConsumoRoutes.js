import express from 'express';
import PrevisaoConsumoController from '../controllers/previsaoConsumoController.js';

const router = express.Router();

// Rota para obter previsões de produção de energia solar
router.get('/', PrevisaoConsumoController.getPrevisaoConsumo);

// Rota para criar uma nova previsão de produção
//router.post('/', PrevisaoConsumoController.createPrevisaoConsumo);

//curl -X GET http://localhost:5000/servicos/crud-dados/previsao-consumo
//curl -X GET http://localhost:5000/servicos/crud-dados/consumo-real

export default router;
