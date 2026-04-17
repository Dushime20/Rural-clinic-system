import swaggerJsdoc from 'swagger-jsdoc';
import { config } from './index';

const options: swaggerJsdoc.Options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'AI Health Companion API',
            version: '1.0.0',
            description: 'Backend API for AI Health Companion - Rural Clinic Disease Diagnosis System',
            contact: {
                name: 'Rural Clinic Health Team',
                email: 'tech-support@ruralclinic.health',
                url: 'https://ruralclinic.health'
            },
            license: {
                name: 'MIT',
                url: 'https://opensource.org/licenses/MIT'
            }
        },
        servers: [
            {
                url: `http://localhost:${config.port}/api/${config.apiVersion}`,
                description: 'Development server'
            },
            {
                url: `https://api.ruralclinic.health/api/${config.apiVersion}`,
                description: 'Production server'
            }
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                    description: 'Enter your JWT token'
                }
            },
            schemas: {
                Error: {
                    type: 'object',
                    properties: {
                        success: {
                            type: 'boolean',
                            example: false
                        },
                        message: {
                            type: 'string',
                            example: 'Error message'
                        },
                        errors: {
                            type: 'array',
                            items: {
                                type: 'object'
                            }
                        }
                    }
                },
                Success: {
                    type: 'object',
                    properties: {
                        success: {
                            type: 'boolean',
                            example: true
                        },
                        message: {
                            type: 'string',
                            example: 'Operation successful'
                        },
                        data: {
                            type: 'object'
                        }
                    }
                }
            }
        },
        security: [
            {
                bearerAuth: []
            }
        ],
        tags: [
            {
                name: 'Authentication',
                description: 'User authentication and authorization endpoints'
            },
            {
                name: 'Patients',
                description: 'Patient management endpoints'
            },
            {
                name: 'Diagnosis',
                description: 'AI-powered disease diagnosis endpoints'
            },
            {
                name: 'Sync',
                description: 'Data synchronization endpoints'
            },
            {
                name: 'Analytics',
                description: 'Analytics and reporting endpoints'
            },
            {
                name: 'Users',
                description: 'User management endpoints'
            }
        ]
    },
    apis: ['./src/routes/*.ts', './src/controllers/*.ts', './src/models/*.ts']
};

export const swaggerSpec = swaggerJsdoc(options);
