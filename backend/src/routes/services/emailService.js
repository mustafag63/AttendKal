import nodemailer from 'nodemailer';
import { config } from '../../config/index.js';
import { logger } from '../../config/logger.js';

// Email templates
const emailTemplates = {
  welcome: {
    subject: 'Welcome to AttendKal! 🎉',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
          <h1 style="color: white; margin: 0;">Welcome to AttendKal!</h1>
        </div>
        <div style="padding: 30px; background: #f8f9fa;">
          <h2 style="color: #333;">Hi {{userName}}! 👋</h2>
          <p style="color: #666; line-height: 1.6;">
            Welcome to AttendKal - your smart attendance tracking companion! 
            We're excited to have you on board.
          </p>
          <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #333; margin-top: 0;">What you can do with AttendKal:</h3>
            <ul style="color: #666; line-height: 1.8;">
              <li>📚 Track attendance for all your courses</li>
              <li>📊 View detailed attendance statistics</li>
              <li>⏰ Get smart reminders before classes</li>
              <li>📋 Generate beautiful attendance reports</li>
              <li>🎯 Set and achieve attendance goals</li>
            </ul>
          </div>
          <div style="text-align: center; margin: 30px 0;">
            <a href="{{appUrl}}" style="background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block;">
              Get Started Now
            </a>
          </div>
          <p style="color: #999; font-size: 12px; text-align: center;">
            Need help? Contact us at support@attendkal.com
          </p>
        </div>
      </div>
    `
  },

  'attendance-reminder': {
    subject: 'Class Reminder: {{courseName}} starts in 15 minutes! ⏰',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: #ff6b6b; padding: 20px; text-align: center;">
          <h1 style="color: white; margin: 0;">⏰ Class Reminder</h1>
        </div>
        <div style="padding: 30px; background: #f8f9fa;">
          <h2 style="color: #333;">Don't forget your class!</h2>
          <div style="background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #ff6b6b;">
            <h3 style="margin-top: 0; color: #333;">{{courseName}}</h3>
            <p style="color: #666; margin: 5px 0;">
              <strong>Time:</strong> {{scheduleTime}}
            </p>
            <p style="color: #666; margin: 5px 0;">
              <strong>Location:</strong> {{room}}
            </p>
          </div>
          <p style="color: #666; margin: 20px 0;">
            Your class starts in 15 minutes. Don't forget to mark your attendance!
          </p>
          <div style="text-align: center;">
            <a href="{{appUrl}}/attendance" style="background: #ff6b6b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block;">
              Mark Attendance
            </a>
          </div>
        </div>
      </div>
    `
  },

  'weekly-report': {
    subject: 'Your Weekly Attendance Report 📊',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #4ecdc4 0%, #26d0ce 100%); padding: 30px; text-align: center;">
          <h1 style="color: white; margin: 0;">📊 Weekly Report</h1>
        </div>
        <div style="padding: 30px; background: #f8f9fa;">
          <h2 style="color: #333;">Week of {{weekStart}} - {{weekEnd}}</h2>
          
          <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #333; margin-top: 0;">Overall Statistics</h3>
            <div style="display: flex; justify-content: space-between; margin: 10px 0;">
              <span style="color: #666;">Attendance Rate:</span>
              <strong style="color: #4ecdc4;">{{attendanceRate}}%</strong>
            </div>
            <div style="display: flex; justify-content: space-between; margin: 10px 0;">
              <span style="color: #666;">Classes Attended:</span>
              <strong>{{attendedClasses}}/{{totalClasses}}</strong>
            </div>
            <div style="display: flex; justify-content: space-between; margin: 10px 0;">
              <span style="color: #666;">Current Streak:</span>
              <strong style="color: #26d0ce;">{{currentStreak}} days</strong>
            </div>
          </div>
          
          <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #333; margin-top: 0;">Course Breakdown</h3>
            {{#each courses}}
            <div style="border-bottom: 1px solid #eee; padding: 10px 0;">
              <div style="display: flex; justify-content: space-between;">
                <strong style="color: {{color}};">{{name}} ({{code}})</strong>
                <span style="color: #666;">{{attendanceRate}}%</span>
              </div>
            </div>
            {{/each}}
          </div>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="{{appUrl}}/reports" style="background: #4ecdc4; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block;">
              View Detailed Report
            </a>
          </div>
        </div>
      </div>
    `
  },

  'password-reset': {
    subject: 'Reset Your AttendKal Password 🔒',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: #f39c12; padding: 20px; text-align: center;">
          <h1 style="color: white; margin: 0;">🔒 Password Reset</h1>
        </div>
        <div style="padding: 30px; background: #f8f9fa;">
          <h2 style="color: #333;">Reset Your Password</h2>
          <p style="color: #666; line-height: 1.6;">
            We received a request to reset your AttendKal password. 
            Click the button below to create a new password.
          </p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="{{resetUrl}}" style="background: #f39c12; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block;">
              Reset Password
            </a>
          </div>
          <p style="color: #999; font-size: 12px;">
            This link will expire in 1 hour. If you didn't request this, please ignore this email.
          </p>
        </div>
      </div>
    `
  }
};

class EmailService {
  constructor() {
    this.transporter = null;
    this.initializeTransporter();
  }

  async initializeTransporter() {
    try {
      // Different transport configurations based on environment
      let transportConfig;

      if (config.server.nodeEnv === 'production') {
        // Production: Use AWS SES or SendGrid
        transportConfig = {
          host: config.email.host,
          port: config.email.port,
          secure: true,
          auth: {
            user: config.email.user,
            pass: config.email.password,
          },
        };
      } else {
        // Development: Use Ethereal for testing
        const testAccount = await nodemailer.createTestAccount();
        transportConfig = {
          host: 'smtp.ethereal.email',
          port: 587,
          secure: false,
          auth: {
            user: testAccount.user,
            pass: testAccount.pass,
          },
        };
      }

      this.transporter = nodemailer.createTransport(transportConfig);

      // Verify connection
      await this.transporter.verify();
      logger.info('Email service initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize email service:', error);
    }
  }

  async sendEmail({ to, subject, template, data, attachments = [] }) {
    try {
      if (!this.transporter) {
        throw new Error('Email transporter not initialized');
      }

      let html, emailSubject;

      if (template && emailTemplates[template]) {
        // Use template
        html = this.compileTemplate(emailTemplates[template].html, data);
        emailSubject = this.compileTemplate(emailTemplates[template].subject, data);
      } else {
        // Direct HTML
        html = data.html || '';
        emailSubject = subject;
      }

      const mailOptions = {
        from: `"AttendKal" <${config.email.from}>`,
        to,
        subject: emailSubject,
        html,
        attachments,
      };

      const result = await this.transporter.sendMail(mailOptions);

      if (config.server.nodeEnv === 'development') {
        logger.info('Preview URL:', nodemailer.getTestMessageUrl(result));
      }

      logger.info(`Email sent successfully to ${to}`);
      return result;
    } catch (error) {
      logger.error(`Failed to send email to ${to}:`, error);
      throw error;
    }
  }

  compileTemplate(template, data) {
    let compiled = template;

    // Simple template compilation (replace {{variable}} with data)
    Object.keys(data || {}).forEach(key => {
      const regex = new RegExp(`{{${key}}}`, 'g');
      compiled = compiled.replace(regex, data[key] || '');
    });

    // Handle arrays (for course breakdown in weekly report)
    if (data && data.courses) {
      const coursePattern = /{{#each courses}}(.*?){{\/each}}/gs;
      compiled = compiled.replace(coursePattern, (match, content) => {
        return data.courses.map(course => {
          let courseHtml = content;
          Object.keys(course).forEach(key => {
            const regex = new RegExp(`{{${key}}}`, 'g');
            courseHtml = courseHtml.replace(regex, course[key] || '');
          });
          return courseHtml;
        }).join('');
      });
    }

    return compiled;
  }

  // Predefined email methods
  async sendWelcomeEmail(userEmail, userName) {
    return this.sendEmail({
      to: userEmail,
      template: 'welcome',
      data: {
        userName,
        appUrl: config.app.frontendUrl,
      },
    });
  }

  async sendAttendanceReminder(userEmail, courseName, scheduleTime, room = '') {
    return this.sendEmail({
      to: userEmail,
      template: 'attendance-reminder',
      data: {
        courseName,
        scheduleTime,
        room,
        appUrl: config.app.frontendUrl,
      },
    });
  }

  async sendWeeklyReport(userEmail, reportData) {
    return this.sendEmail({
      to: userEmail,
      template: 'weekly-report',
      data: {
        ...reportData,
        appUrl: config.app.frontendUrl,
      },
    });
  }

  async sendPasswordReset(userEmail, resetToken) {
    const resetUrl = `${config.app.frontendUrl}/reset-password?token=${resetToken}`;

    return this.sendEmail({
      to: userEmail,
      template: 'password-reset',
      data: {
        resetUrl,
      },
    });
  }
}

// Export singleton instance
export const emailService = new EmailService();
export const sendEmail = emailService.sendEmail.bind(emailService);
export default emailService; 