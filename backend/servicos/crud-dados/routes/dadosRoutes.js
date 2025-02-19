import express from 'express';
import { receberJson } from '../controllers/controllerMedidor.js'; // ✅ Chama o controller para processar o JSON recebido

const router = express.Router();

// ✅ Rota para receber qualquer JSON via POST
router.post('/receber-json', receberJson);

export default router;
