import express from 'express';
import { inserirDadosArquivo } from '../controllers/controllerMedidor.js';

const router = express.Router();

// ✅ Chama corretamente o controller
router.get('/testeDados1', inserirDadosArquivo);

export default router;
