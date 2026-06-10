/**
 * Input Sanitization Middleware
 * 
 * Additional security layer for sanitizing user inputs
 * to prevent XSS, SQL injection, and other injection attacks.
 * 
 * Note: TypeORM uses parameterized queries by default, which protects
 * against SQL injection. This middleware provides additional defense.
 */

import { Request, Response, NextFunction } from 'express';

/**
 * HTML entity encoding to prevent XSS attacks
 */
const escapeHtml = (str: string): string => {
    if (typeof str !== 'string') return str;
    
    const htmlEntities: Record<string, string> = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#x27;',
        '/': '&#x2F;',
    };
    
    return str.replace(/[&<>"'/]/g, (char) => htmlEntities[char]);
};

/**
 * Remove potentially dangerous SQL characters from strings
 * This is a defense-in-depth measure; TypeORM parameterized queries
 * are the primary SQL injection protection.
 */
const sanitizeSqlString = (str: string): string => {
    if (typeof str !== 'string') return str;
    
    // Remove SQL comments and multiple dashes
    return str
        .replace(/--/g, '')
        .replace(/\/\*/g, '')
        .replace(/\*\//g, '')
        .replace(/;/g, ''); // Remove semicolons to prevent query chaining
};

/**
 * Sanitize coordinate values
 * Ensures latitude and longitude are within valid ranges
 */
export const sanitizeCoordinates = (
    latitude?: number | string,
    longitude?: number | string
): { latitude?: number; longitude?: number; isValid: boolean } => {
    if (latitude === undefined && longitude === undefined) {
        return { isValid: true };
    }
    
    const lat = typeof latitude === 'string' ? parseFloat(latitude) : latitude;
    const lon = typeof longitude === 'string' ? parseFloat(longitude) : longitude;
    
    // Check if values are valid numbers
    if (lat !== undefined && (isNaN(lat) || lat < -90 || lat > 90)) {
        return { isValid: false };
    }
    
    if (lon !== undefined && (isNaN(lon) || lon < -180 || lon > 180)) {
        return { isValid: false };
    }
    
    return {
        latitude: lat,
        longitude: lon,
        isValid: true,
    };
};

/**
 * Sanitize email address
 */
export const sanitizeEmail = (email: string): string => {
    if (typeof email !== 'string') return email;
    
    // Convert to lowercase and trim
    return email.toLowerCase().trim();
};

/**
 * Sanitize phone number
 */
export const sanitizePhoneNumber = (phone: string): string => {
    if (typeof phone !== 'string') return phone;
    
    // Remove all non-digit characters except + at the start
    let sanitized = phone.trim();
    if (sanitized.startsWith('+')) {
        sanitized = '+' + sanitized.slice(1).replace(/\D/g, '');
    } else {
        sanitized = sanitized.replace(/\D/g, '');
    }
    
    return sanitized;
};

/**
 * Sanitize string input for general text fields
 */
export const sanitizeString = (str: string, options?: { 
    allowHtml?: boolean;
    maxLength?: number;
}): string => {
    if (typeof str !== 'string') return str;
    
    let sanitized = str.trim();
    
    // Apply max length
    if (options?.maxLength) {
        sanitized = sanitized.slice(0, options.maxLength);
    }
    
    // Escape HTML by default
    if (!options?.allowHtml) {
        sanitized = escapeHtml(sanitized);
    }
    
    // Remove SQL-dangerous characters
    sanitized = sanitizeSqlString(sanitized);
    
    return sanitized;
};

/**
 * Middleware to sanitize request body
 * Apply this after express-validator validation
 */
export const sanitizeRequestBody = (req: Request, res: Response, next: NextFunction): void => {
    if (!req.body || typeof req.body !== 'object') {
        return next();
    }
    
    const sanitizeObject = (obj: any): any => {
        if (typeof obj !== 'object' || obj === null) {
            return obj;
        }
        
        if (Array.isArray(obj)) {
            return obj.map(item => sanitizeObject(item));
        }
        
        const sanitized: any = {};
        for (const [key, value] of Object.entries(obj)) {
            if (typeof value === 'string') {
                // Special handling for specific fields
                if (key === 'email') {
                    sanitized[key] = sanitizeEmail(value);
                } else if (key === 'phoneNumber' || key === 'phone') {
                    sanitized[key] = sanitizePhoneNumber(value);
                } else if (key.includes('latitude') || key.includes('longitude')) {
                    // Coordinates are validated separately
                    sanitized[key] = value;
                } else {
                    // General string sanitization
                    sanitized[key] = sanitizeString(value, { maxLength: 10000 });
                }
            } else if (typeof value === 'object') {
                sanitized[key] = sanitizeObject(value);
            } else {
                sanitized[key] = value;
            }
        }
        
        return sanitized;
    };
    
    req.body = sanitizeObject(req.body);
    next();
};

/**
 * Middleware to sanitize query parameters
 */
export const sanitizeQueryParams = (req: Request, res: Response, next: NextFunction): void => {
    if (!req.query || typeof req.query !== 'object') {
        return next();
    }
    
    const sanitized: any = {};
    for (const [key, value] of Object.entries(req.query)) {
        if (typeof value === 'string') {
            sanitized[key] = sanitizeString(value, { maxLength: 1000 });
        } else {
            sanitized[key] = value;
        }
    }
    
    req.query = sanitized;
    next();
};

/**
 * Middleware to prevent NoSQL injection in MongoDB queries
 * (Not currently used since we're using PostgreSQL + TypeORM,
 * but included for future-proofing)
 */
export const preventNoSQLInjection = (req: Request, res: Response, next: NextFunction): void => {
    const sanitizeNoSQL = (obj: any): any => {
        if (typeof obj !== 'object' || obj === null) {
            return obj;
        }
        
        if (Array.isArray(obj)) {
            return obj.map(item => sanitizeNoSQL(item));
        }
        
        const sanitized: any = {};
        for (const [key, value] of Object.entries(obj)) {
            // Remove MongoDB operators
            if (key.startsWith('$')) {
                continue;
            }
            
            sanitized[key] = sanitizeNoSQL(value);
        }
        
        return sanitized;
    };
    
    if (req.body) {
        req.body = sanitizeNoSQL(req.body);
    }
    
    if (req.query) {
        req.query = sanitizeNoSQL(req.query);
    }
    
    next();
};

export default {
    sanitizeRequestBody,
    sanitizeQueryParams,
    preventNoSQLInjection,
    sanitizeCoordinates,
    sanitizeEmail,
    sanitizePhoneNumber,
    sanitizeString,
};
