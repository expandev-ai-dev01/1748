import { Router } from 'express';
import internalRoutes from './internalRoutes';
import externalRoutes from './externalRoutes';

const router = Router();

// Internal routes (require authentication) will be prefixed with /api/v1/internal
router.use('/internal', internalRoutes);

// External routes (public) will be prefixed with /api/v1/external
router.use('/external', externalRoutes);

export default router;
