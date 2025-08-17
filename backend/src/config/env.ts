import dotenv from 'dotenv';

dotenv.config();

export const config = {
    port: process.env.PORT || 3000,
    nodeEnv: process.env.NODE_ENV || 'development',
    jwtSecret: process.env.JWT_SECRET || 'your-super-secret-jwt-key',
    databaseUrl: process.env.DATABASE_URL || 'postgresql://username:password@localhost:5432/attendkal',
    version: process.env.npm_package_version || '1.0.0',
};

export const isDevelopment = config.nodeEnv === 'development';
export const isProduction = config.nodeEnv === 'production';
