import request from 'supertest';
import app from '../src/app';

describe('API Health Check', () => {
    test('GET /health should return 200', async () => {
        const response = await request(app)
            .get('/health')
            .expect(200);

        expect(response.body).toEqual({
            status: 'OK',
            timestamp: expect.any(String)
        });
    });
});

describe('Authentication Endpoints', () => {
    test('POST /api/auth/register should validate required fields', async () => {
        const response = await request(app)
            .post('/api/auth/register')
            .send({})
            .expect(400);

        expect(response.body.error).toContain('validation');
    });

    test('POST /api/auth/login should validate credentials', async () => {
        const response = await request(app)
            .post('/api/auth/login')
            .send({ email: 'invalid', password: 'invalid' })
            .expect(401);

        expect(response.body.error).toBeDefined();
    });
});

describe('Course Endpoints', () => {
    test('GET /api/courses should require authentication', async () => {
        const response = await request(app)
            .get('/api/courses')
            .expect(401);

        expect(response.body.error).toContain('authentication');
    });
});
