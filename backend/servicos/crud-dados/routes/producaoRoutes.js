import express from 'express';
import ProducaoController from '../controllers/producaoController.js';

const router = express.Router();

// Rota para obter dados reais de produção de energia solar
router.get('/', ProducaoController.getProducaoReal);

// Rota para registrar uma nova produção real
//router.post('/', ProducaoController.createProducaoReal);

export default router;
