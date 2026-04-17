import 'reflect-metadata';
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { config } from './config';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { notFoundHandler } from './middleware/not-found';
import routes from './routes';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';

class App {
    public app: Application;

    constructor() {
        this.app = express();
        this.initializeMiddlewares();
        this.initializeRoutes();
        this.initializeErrorHandling();
    }

    private initializeMiddlewares(): void {
        // Security middleware
        this.app.use(helmet());

        // CORS configuration
        this.app.use(cors({
            origin: config.corsOrigin,
            credentials: true,
            methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
            allowedHeaders: ['Content-Type', 'Authorization']
        }));

        // Body parsing middleware
        this.app.use(express.json({ limit: '10mb' }));
        this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

        // Compression middleware
        this.app.use(compression());

        // Logging middleware
        if (config.nodeEnv === 'development') {
            this.app.use(morgan('dev'));
        } else {
            this.app.use(morgan('combined', {
                stream: { write: (message: string) => logger.info(message.trim()) }
            }));
        }

        // Health check endpoint
        this.app.get('/health', (_req: Request, res: Response) => {
            res.status(200).json({
                status: 'healthy',
                timestamp: new Date().toISOString(),
                uptime: process.uptime(),
                environment: config.nodeEnv
            });
        });
    }

    private initializeRoutes(): void {
        // API documentation
        this.app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

        // API routes
        this.app.use(`/api/${config.apiVersion}`, routes);

        // 404 handler
        this.app.use(notFoundHandler);
    }

    private initializeErrorHandling(): void {
        this.app.use(errorHandler);
    }
}

export const app = new App().app;
