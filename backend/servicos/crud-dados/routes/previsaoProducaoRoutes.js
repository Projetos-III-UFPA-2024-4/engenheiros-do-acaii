import express from 'express';
import PrevisaoProducaoController from '../controllers/previsaoProducaoController.js';

const router = express.Router();

// Rota para obter previsões de produção de energia solar
router.get('/', PrevisaoProducaoController.getPrevisaoProducao);

// Rota para criar uma nova previsão de produção
//router.post('/', PrevisaoProducaoController.createPrevisaoProducao);

//curl -X GET http://localhost:5000/servicos/crud-dados/previsao-producao
//curl -X GET http://localhost:5000/servicos/crud-dados/producao-real

export default router;
