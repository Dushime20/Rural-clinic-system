import { DataSource } from 'typeorm';
import { AppDataSource } from './data-source';
import { logger } from '../utils/logger';

export const connectDatabase = async (): Promise<void> => {
    try {
        await AppDataSource.initialize();
        logger.info(`PostgreSQL connected: ${AppDataSource.options.database}`);


    } catch (error) {
        logger.error('Failed to connect to PostgreSQL:', error);
        throw error;
    }
};

export const disconnectDatabase = async (): Promise<void> => {
    try {
        if (AppDataSource.isInitialized) {
            await AppDataSource.destroy();
            logger.info('PostgreSQL disconnected successfully');
        }
    } catch (error) {
        logger.error('Error disconnecting from PostgreSQL:', error);
        throw error;
    }
};

export default { connectDatabase, disconnectDatabase };
