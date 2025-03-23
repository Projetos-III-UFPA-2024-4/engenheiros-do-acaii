// routes/alertaRoutes.js
import express from 'express';
import { receberAlerta } from '../controllers/alertaController.js';

const router = express.Router();

// Rota para receber o alerta via POST
router.post('/', receberAlerta);

export default router;
