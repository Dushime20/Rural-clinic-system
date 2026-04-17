import 'reflect-metadata';
import { app } from './app';
import { config } from './config';
import { initializeDatabase } from './database/data-source';
import { logger } from './utils/logger';

async function startServer(): Promise<void> {
    try {
        const port = config.port;

        // Connect to database
        await initializeDatabase();
        logger.info('Database connected successfully');

        // Start server
        app.listen(port, () => {
            logger.info(`🚀 Server running on port ${port} in ${config.nodeEnv} mode`);
            logger.info(`📚 API Documentation: http://localhost:${port}/api-docs`);
            logger.info(`🏥 Health Check: http://localhost:${port}/health`);
        });
    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason: Error) => {
    logger.error('Unhandled Rejection:', reason);
    process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error: Error) => {
    logger.error('Uncaught Exception:', error);
    process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    logger.info('SIGTERM signal received: closing HTTP server');
    process.exit(0);
});

// Start the server
startServer();
