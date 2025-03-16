import express from 'express';
import PrevisaoProducaoController from '../controllers/previsaoProducaoController.js';

const router = express.Router();

// Rota para obter previsões de produção de energia solar
router.get('/', PrevisaoProducaoController.getPrevisaoProducao);

// Rota para criar uma nova previsão de produção
//router.post('/', PrevisaoProducaoController.createPrevisaoProducao);

export default router;
