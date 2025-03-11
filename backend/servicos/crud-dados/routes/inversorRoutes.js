import express from 'express';
import { receberDadosInversor } from '../controllers/controllerInversor.js'; // ✅ Chama o controller para processar o JSON recebido

const router = express.Router();

// ✅ Rota para receber qualquer JSON via POST
router.post('/', receberDadosInversor);

export default router;
