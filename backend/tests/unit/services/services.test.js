import { jest } from '@jest/globals';

describe('Services Integration Tests', () => {
    describe('AuthService', () => {
        test('should import successfully', async () => {
            const { authService, AuthService } = await import('../../../src/routes/services/authService.js');
            expect(authService).toBe(AuthService);
            expect(typeof authService.generateTokens).toBe('function');
            expect(typeof authService.registerUser).toBe('function');
            expect(typeof authService.authenticateUser).toBe('function');
        });
    });

    describe('CourseService', () => {
        test('should import successfully', async () => {
            const { courseService, CourseService } = await import('../../../src/routes/services/courseService.js');
            expect(courseService).toBe(CourseService);
            expect(typeof courseService.createCourse).toBe('function');
            expect(typeof courseService.getUserCourses).toBe('function');
            expect(typeof courseService.getCourseById).toBe('function');
        });
    });

    describe('AttendanceService', () => {
        test('should import successfully', async () => {
            const { attendanceService, AttendanceService } = await import('../../../src/routes/services/attendanceService.js');
            expect(attendanceService).toBe(AttendanceService);
            expect(typeof attendanceService.markAttendance).toBe('function');
            expect(typeof attendanceService.getAttendance).toBe('function');
            expect(typeof attendanceService.getCourseAttendance).toBe('function');
        });
    });

    describe('SubscriptionService', () => {
        test('should import successfully', async () => {
            const { subscriptionService, SubscriptionService } = await import('../../../src/routes/services/subscriptionService.js');
            expect(subscriptionService).toBeInstanceOf(SubscriptionService);
            expect(typeof subscriptionService.getSubscription).toBe('function');
            expect(typeof subscriptionService.createSubscription).toBe('function');
            expect(typeof subscriptionService.changeSubscriptionPlan).toBe('function');
            expect(typeof subscriptionService.upgradeSubscription).toBe('function');
        });

        test('should allow free plan changes', async () => {
            const { subscriptionService } = await import('../../../src/routes/services/subscriptionService.js');
            const plans = await subscriptionService.getSubscriptionPlans();

            expect(plans).toHaveLength(2);
            expect(plans.map(p => p.id)).toContain('FREE');
            expect(plans.map(p => p.id)).toContain('PREMIUM');

            // Check FREE plan has 2 course limit
            const freePlan = plans.find(p => p.id === 'FREE');
            expect(freePlan.courseLimit).toBe(2);

            // Premium plan should indicate it's free during beta
            const premiumPlan = plans.find(p => p.id === 'PREMIUM');
            expect(premiumPlan.priceNote).toContain('Free during beta');
            expect(premiumPlan.isRecommended).toBe(true);
        });
    });

    describe('Cross-service functionality', () => {
        test('all services should be defined and ready', async () => {
            const [
                { authService },
                { courseService },
                { attendanceService },
                { subscriptionService }
            ] = await Promise.all([
                import('../../../src/routes/services/authService.js'),
                import('../../../src/routes/services/courseService.js'),
                import('../../../src/routes/services/attendanceService.js'),
                import('../../../src/routes/services/subscriptionService.js')
            ]);

            expect(authService).toBeDefined();
            expect(courseService).toBeDefined();
            expect(attendanceService).toBeDefined();
            expect(subscriptionService).toBeDefined();
        });
    });
}); 