import admin from 'firebase-admin';

class FirebaseAdminService {
    private static instance: FirebaseAdminService;
    private app: admin.app.App | null = null;

    private constructor() { }

    public static getInstance(): FirebaseAdminService {
        if (!FirebaseAdminService.instance) {
            FirebaseAdminService.instance = new FirebaseAdminService();
        }
        return FirebaseAdminService.instance;
    }

    /**
     * Initialize Firebase Admin SDK
     */
    public initialize(): boolean {
        try {
            // Check if already initialized
            if (this.app) {
                return true;
            }

            const serviceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;

            if (!serviceAccountKey) {
                console.warn('Firebase service account key not found. Push notifications will be disabled.');
                return false;
            }

            // Parse the service account key
            const serviceAccount = JSON.parse(serviceAccountKey);

            // Initialize Firebase Admin
            this.app = admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                projectId: serviceAccount.project_id,
            });

            console.log('Firebase Admin SDK initialized successfully');
            return true;

        } catch (error) {
            console.error('Error initializing Firebase Admin SDK:', error);
            return false;
        }
    }

    /**
     * Send notification to a single device token
     */
    public async sendNotificationToToken(
        token: string,
        title: string,
        body: string,
        data?: Record<string, string>
    ): Promise<boolean> {
        if (!this.app) {
            console.warn('Firebase Admin not initialized. Cannot send notification.');
            return false;
        }

        try {
            const message: admin.messaging.Message = {
                token,
                notification: {
                    title,
                    body,
                },
                data: data || {},
                android: {
                    notification: {
                        channelId: 'attendkal_push',
                        priority: 'high' as const,
                        defaultSound: true,
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                title,
                                body,
                            },
                            badge: 1,
                            sound: 'default',
                            category: 'ATTENDANCE_CATEGORY',
                        },
                    },
                },
            };

            const response = await admin.messaging().send(message);
            console.log('Successfully sent message:', response);
            return true;

        } catch (error) {
            console.error('Error sending notification to token:', error);
            return false;
        }
    }

    /**
     * Send notification to multiple tokens
     */
    public async sendNotificationToTokens(
        tokens: string[],
        title: string,
        body: string,
        data?: Record<string, string>
    ): Promise<{ successCount: number; failureCount: number }> {
        if (!this.app) {
            console.warn('Firebase Admin not initialized. Cannot send notifications.');
            return { successCount: 0, failureCount: tokens.length };
        }

        if (tokens.length === 0) {
            return { successCount: 0, failureCount: 0 };
        }

        try {
            const message: admin.messaging.MulticastMessage = {
                tokens,
                notification: {
                    title,
                    body,
                },
                data: data || {},
                android: {
                    notification: {
                        channelId: 'attendkal_push',
                        priority: 'high' as const,
                        defaultSound: true,
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                title,
                                body,
                            },
                            badge: 1,
                            sound: 'default',
                            category: 'ATTENDANCE_CATEGORY',
                        },
                    },
                },
            };

            const response = await admin.messaging().sendEachForMulticast(message);

            console.log(`Successfully sent ${response.successCount} notifications`);
            console.log(`Failed to send ${response.failureCount} notifications`);

            // Log individual failures for debugging
            response.responses.forEach((resp: any, idx: number) => {
                if (!resp.success) {
                    console.error(`Failed to send to token ${tokens[idx]}:`, resp.error);
                }
            });

            return {
                successCount: response.successCount,
                failureCount: response.failureCount,
            };

        } catch (error) {
            console.error('Error sending notifications to tokens:', error);
            return { successCount: 0, failureCount: tokens.length };
        }
    }

    /**
     * Send notification to topic
     */
    public async sendNotificationToTopic(
        topic: string,
        title: string,
        body: string,
        data?: Record<string, string>
    ): Promise<boolean> {
        if (!this.app) {
            console.warn('Firebase Admin not initialized. Cannot send notification.');
            return false;
        }

        try {
            const message: admin.messaging.Message = {
                topic,
                notification: {
                    title,
                    body,
                },
                data: data || {},
                android: {
                    notification: {
                        channelId: 'attendkal_push',
                        priority: 'high' as const,
                        defaultSound: true,
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                title,
                                body,
                            },
                            badge: 1,
                            sound: 'default',
                            category: 'ATTENDANCE_CATEGORY',
                        },
                    },
                },
            };

            const response = await admin.messaging().send(message);
            console.log('Successfully sent message to topic:', response);
            return true;

        } catch (error) {
            console.error('Error sending notification to topic:', error);
            return false;
        }
    }

    /**
     * Send notification to user (all their active tokens)
     */
    public async sendNotificationToUser(
        userId: string,
        title: string,
        body: string,
        data?: Record<string, string>
    ): Promise<{ successCount: number; failureCount: number }> {
        try {
            // TODO: Get user's active FCM tokens from database
            // For now, return mock response
            console.log(`Sending notification to user ${userId}: ${title}`);

            return { successCount: 0, failureCount: 0 };

        } catch (error) {
            console.error('Error sending notification to user:', error);
            return { successCount: 0, failureCount: 1 };
        }
    }

    /**
     * Send reminder notification
     */
    public async sendReminderNotification(
        userId: string,
        reminderId: string,
        title: string,
        body: string,
        courseId?: string,
        sessionId?: string
    ): Promise<boolean> {
        const data: Record<string, string> = {
            type: 'reminder',
            reminderId,
            targetId: reminderId,
        };

        if (courseId) data.courseId = courseId;
        if (sessionId) data.sessionId = sessionId;

        const result = await this.sendNotificationToUser(userId, title, body, data);
        return result.successCount > 0;
    }

    /**
     * Send attendance reminder notification
     */
    public async sendAttendanceReminder(
        userId: string,
        sessionId: string,
        courseTitle: string,
        reminderType: 'morning' | 'preStart'
    ): Promise<boolean> {
        let title: string;
        let body: string;

        switch (reminderType) {
            case 'morning':
                title = '🌅 Bugün ders var!';
                body = `${courseTitle} dersiniz bugün var. Hazır olun!`;
                break;
            case 'preStart':
                title = '📚 Ders yaklaşıyor';
                body = `${courseTitle} dersiniz 30 dakika içinde başlayacak.`;
                break;
        }

        const data: Record<string, string> = {
            type: 'attendance',
            sessionId,
            targetId: sessionId,
            reminderType,
        };

        const result = await this.sendNotificationToUser(userId, title, body, data);
        return result.successCount > 0;
    }

    /**
     * Check if Firebase Admin is initialized
     */
    public isInitialized(): boolean {
        return this.app !== null;
    }
}

export default FirebaseAdminService;
