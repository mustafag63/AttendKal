import Bull from 'bull';
import { config } from '../config/index.js';
import { logger } from '../config/logger.js';
import { sendEmail } from './emailService.js';
import { generateAttendanceReport } from './reportService.js';

// Initialize Redis connection
const redisConfig = {
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password,
  maxRetriesPerRequest: 3,
};

// Define different queues for different job types
export const emailQueue = new Bull('email queue', {
  redis: redisConfig,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
    removeOnComplete: 50,
    removeOnFail: 50,
  },
});

export const reportQueue = new Bull('report queue', {
  redis: redisConfig,
  defaultJobOptions: {
    attempts: 2,
    backoff: {
      type: 'exponential',
      delay: 5000,
    },
    removeOnComplete: 20,
    removeOnFail: 20,
  },
});

export const notificationQueue = new Bull('notification queue', {
  redis: redisConfig,
  defaultJobOptions: {
    attempts: 5,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
    removeOnComplete: 100,
    removeOnFail: 50,
  },
});

// Email Queue Processors
emailQueue.process('welcome-email', async (job) => {
  const { userEmail, userName } = job.data;

  logger.info(`Processing welcome email for ${userEmail}`);

  try {
    await sendEmail({
      to: userEmail,
      subject: 'Welcome to AttendKal! 🎉',
      template: 'welcome',
      data: { userName },
    });

    logger.info(`Welcome email sent successfully to ${userEmail}`);
  } catch (error) {
    logger.error(`Failed to send welcome email to ${userEmail}:`, error);
    throw error;
  }
});

emailQueue.process('attendance-reminder', async (job) => {
  const { userEmail, courseName, scheduleTime } = job.data;

  try {
    await sendEmail({
      to: userEmail,
      subject: `Reminder: ${courseName} class starts soon`,
      template: 'attendance-reminder',
      data: { courseName, scheduleTime },
    });

    logger.info(`Attendance reminder sent to ${userEmail} for ${courseName}`);
  } catch (error) {
    logger.error('Failed to send attendance reminder:', error);
    throw error;
  }
});

emailQueue.process('weekly-report', async (job) => {
  const { userEmail, userId, weekStart, weekEnd } = job.data;

  try {
    const reportData = await generateAttendanceReport(userId, weekStart, weekEnd);

    await sendEmail({
      to: userEmail,
      subject: 'Your Weekly Attendance Report 📊',
      template: 'weekly-report',
      data: reportData,
      attachments: [
        {
          filename: 'weekly-report.pdf',
          content: reportData.pdfBuffer,
        },
      ],
    });

    logger.info(`Weekly report sent to ${userEmail}`);
  } catch (error) {
    logger.error('Failed to send weekly report:', error);
    throw error;
  }
});

// Report Queue Processors
reportQueue.process('generate-pdf-report', async (job) => {
  const { userId, courseId, startDate, endDate, format } = job.data;

  try {
    logger.info(`Generating ${format} report for user ${userId}`);

    const report = await generateAttendanceReport(userId, startDate, endDate, {
      courseId,
      format,
    });

    // Store report in file system or cloud storage
    const reportUrl = await storeReport(report, userId);

    // Notify user that report is ready
    await notificationQueue.add('report-ready', {
      userId,
      reportUrl,
      format,
    });

    logger.info(`Report generated and stored: ${reportUrl}`);
    return { reportUrl };
  } catch (error) {
    logger.error('Failed to generate report:', error);
    throw error;
  }
});

// Notification Queue Processors
notificationQueue.process('push-notification', async (job) => {
  const { userId, title, body, data } = job.data;

  try {
    // Send push notification via Firebase FCM
    await sendPushNotification(userId, {
      title,
      body,
      data,
    });

    logger.info(`Push notification sent to user ${userId}`);
  } catch (error) {
    logger.error('Failed to send push notification:', error);
    throw error;
  }
});

notificationQueue.process('report-ready', async (job) => {
  const { userId, reportUrl, format } = job.data;

  try {
    await notificationQueue.add('push-notification', {
      userId,
      title: 'Report Ready! 📋',
      body: `Your ${format} attendance report is ready for download`,
      data: { reportUrl, type: 'report' },
    });
  } catch (error) {
    logger.error('Failed to notify user about ready report:', error);
    throw error;
  }
});

// Queue Event Handlers
emailQueue.on('completed', (job, result) => {
  logger.info(`Email job ${job.id} completed:`, result);
});

emailQueue.on('failed', (job, err) => {
  logger.error(`Email job ${job.id} failed:`, err.message);
});

reportQueue.on('completed', (job, result) => {
  logger.info(`Report job ${job.id} completed:`, result);
});

reportQueue.on('failed', (job, err) => {
  logger.error(`Report job ${job.id} failed:`, err.message);
});

// Helper Functions
export const queueJobs = {
  // Send welcome email to new users
  sendWelcomeEmail: async (userEmail, userName) => {
    return emailQueue.add('welcome-email', {
      userEmail,
      userName,
    });
  },

  // Schedule attendance reminders
  scheduleAttendanceReminder: async (userEmail, courseName, scheduleTime) => {
    const delay = new Date(scheduleTime).getTime() - Date.now() - (15 * 60 * 1000); // 15 minutes before

    if (delay > 0) {
      return emailQueue.add('attendance-reminder', {
        userEmail,
        courseName,
        scheduleTime,
      }, { delay });
    }
  },

  // Schedule weekly reports
  scheduleWeeklyReport: async (userEmail, userId) => {
    const nextMonday = getNextMonday();

    return emailQueue.add('weekly-report', {
      userEmail,
      userId,
      weekStart: new Date(nextMonday.getTime() - 7 * 24 * 60 * 60 * 1000),
      weekEnd: nextMonday,
    }, {
      repeat: { cron: '0 9 * * MON' }, // Every Monday at 9 AM
    });
  },

  // Generate attendance reports
  generateReport: async (userId, options = {}) => {
    return reportQueue.add('generate-pdf-report', {
      userId,
      ...options,
    });
  },

  // Send push notifications
  sendNotification: async (userId, notification) => {
    return notificationQueue.add('push-notification', {
      userId,
      ...notification,
    });
  },
};

// Utility functions
function getNextMonday() {
  const today = new Date();
  const nextMonday = new Date(today);
  nextMonday.setDate(today.getDate() + ((1 + 7 - today.getDay()) % 7 || 7));
  nextMonday.setHours(0, 0, 0, 0);
  return nextMonday;
}

async function storeReport(report, userId) {
  // Implementation would store file and return URL
  // This could be AWS S3, Google Cloud Storage, etc.
  return `https://reports.attendkal.com/${userId}/${Date.now()}.pdf`;
}

async function sendPushNotification(userId, notification) {
  // Implementation would use Firebase FCM or similar service
  logger.info(`Sending push notification to user ${userId}:`, notification);
}

export default {
  emailQueue,
  reportQueue,
  notificationQueue,
  queueJobs,
}; 