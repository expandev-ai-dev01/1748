import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import dotenv from 'dotenv';

dotenv.config();

import { config } from '@/config';
import { errorMiddleware } from '@/middleware/errorMiddleware';
import { notFoundMiddleware } from '@/middleware/notFoundMiddleware';
import apiRoutes from '@/routes';
import { connectToDatabase } from '@/utils/database';

const app: Application = express();

// Security and Performance Middleware
app.use(helmet());
app.use(cors(config.api.cors));
app.use(compression());

// Request Processing Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging Middleware
if (config.env !== 'production') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Health Check Endpoint (unversioned)
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API Routes (versioned)
app.use('/api', apiRoutes);

// 404 Not Found Handler
app.use(notFoundMiddleware);

// Global Error Handling Middleware
app.use(errorMiddleware);

const startServer = async () => {
  try {
    await connectToDatabase();
    console.log('Database connection successful.');

    const server = app.listen(config.api.port, () => {
      console.log(`Server running on port ${config.api.port} in ${config.env} mode`);
    });

    // Graceful Shutdown
    process.on('SIGTERM', () => {
      console.log('SIGTERM received, closing server gracefully.');
      server.close(() => {
        console.log('Server closed.');
        process.exit(0);
      });
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
