import express from 'express';
import { authenticate, restrictTo } from '../middleware/authMiddleware.js';
import { emailQueue, reportQueue, notificationQueue, queueJobs } from './services/queueService.js';
import { catchAsync } from '../middleware/errorHandler.js';

const router = express.Router();

// Protect all queue routes - only admins can access
router.use(authenticate);
router.use(restrictTo('ADMIN'));

/**
 * @swagger
 * /admin/queues/status:
 *   get:
 *     summary: Get queue status overview
 *     tags: [Queue Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Queue status information
 */
router.get('/status', catchAsync(async (req, res) => {
  const [emailStats, reportStats, notificationStats] = await Promise.all([
    getQueueStats(emailQueue),
    getQueueStats(reportQueue),
    getQueueStats(notificationQueue),
  ]);

  res.json({
    status: 'success',
    data: {
      queues: {
        email: emailStats,
        report: reportStats,
        notification: notificationStats,
      },
      timestamp: new Date().toISOString(),
    },
  });
}));

/**
 * @swagger
 * /admin/queues/{queueName}/jobs:
 *   get:
 *     summary: Get jobs in queue
 *     tags: [Queue Management]
 *     parameters:
 *       - in: path
 *         name: queueName
 *         required: true
 *         schema:
 *           type: string
 *           enum: [email, report, notification]
 *     security:
 *       - bearerAuth: []
 */
router.get('/:queueName/jobs', catchAsync(async (req, res) => {
  const { queueName } = req.params;
  const { status = 'waiting', start = 0, end = 10 } = req.query;

  const queue = getQueueByName(queueName);
  if (!queue) {
    return res.status(404).json({
      status: 'error',
      message: 'Queue not found',
    });
  }

  const jobs = await queue.getJobs([status], parseInt(start), parseInt(end));
  const jobsWithDetails = jobs.map(job => ({
    id: job.id,
    name: job.name,
    data: job.data,
    progress: job.progress(),
    delay: job.delay,
    timestamp: job.timestamp,
    processedOn: job.processedOn,
    finishedOn: job.finishedOn,
    failedReason: job.failedReason,
    attemptsMade: job.attemptsMade,
    opts: job.opts,
  }));

  res.json({
    status: 'success',
    data: {
      queueName,
      status,
      jobs: jobsWithDetails,
      total: jobsWithDetails.length,
    },
  });
}));

/**
 * @swagger
 * /admin/queues/{queueName}/jobs/{jobId}/retry:
 *   post:
 *     summary: Retry a failed job
 *     tags: [Queue Management]
 */
router.post('/:queueName/jobs/:jobId/retry', catchAsync(async (req, res) => {
  const { queueName, jobId } = req.params;

  const queue = getQueueByName(queueName);
  if (!queue) {
    return res.status(404).json({
      status: 'error',
      message: 'Queue not found',
    });
  }

  const job = await queue.getJob(jobId);
  if (!job) {
    return res.status(404).json({
      status: 'error',
      message: 'Job not found',
    });
  }

  await job.retry();

  res.json({
    status: 'success',
    message: 'Job retried successfully',
    data: { jobId, queueName },
  });
}));

/**
 * @swagger
 * /admin/queues/{queueName}/clean:
 *   post:
 *     summary: Clean queue (remove completed/failed jobs)
 *     tags: [Queue Management]
 */
router.post('/:queueName/clean', catchAsync(async (req, res) => {
  const { queueName } = req.params;
  const { grace = 24 * 60 * 60 * 1000, status = 'completed' } = req.body; // 24 hours default

  const queue = getQueueByName(queueName);
  if (!queue) {
    return res.status(404).json({
      status: 'error',
      message: 'Queue not found',
    });
  }

  const cleanedJobs = await queue.clean(grace, status);

  res.json({
    status: 'success',
    message: `Cleaned ${cleanedJobs.length} ${status} jobs`,
    data: { queueName, cleanedCount: cleanedJobs.length },
  });
}));

/**
 * @swagger
 * /admin/queues/test/email:
 *   post:
 *     summary: Test email queue
 *     tags: [Queue Management]
 */
router.post('/test/email', catchAsync(async (req, res) => {
  const { email = req.user.email, type = 'welcome' } = req.body;

  let job;
  switch (type) {
  case 'welcome':
    job = await queueJobs.sendWelcomeEmail(email, req.user.name);
    break;
  case 'reminder':
    job = await queueJobs.scheduleAttendanceReminder(
      email,
      'Test Course',
      new Date(Date.now() + 60000).toISOString() // 1 minute from now
    );
    break;
  default:
    return res.status(400).json({
      status: 'error',
      message: 'Invalid email type',
    });
  }

  res.json({
    status: 'success',
    message: 'Test email queued successfully',
    data: { jobId: job.id, type, email },
  });
}));

/**
 * @swagger
 * /admin/queues/test/report:
 *   post:
 *     summary: Test report generation
 *     tags: [Queue Management]
 */
router.post('/test/report', catchAsync(async (req, res) => {
  const {
    format = 'pdf',
    startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days ago
    endDate = new Date().toISOString()
  } = req.body;

  const job = await queueJobs.generateReport(req.user.id, {
    format,
    startDate,
    endDate,
  });

  res.json({
    status: 'success',
    message: 'Report generation queued successfully',
    data: { jobId: job.id, format, userId: req.user.id },
  });
}));

/**
 * @swagger
 * /admin/queues/pause/{queueName}:
 *   post:
 *     summary: Pause a queue
 *     tags: [Queue Management]
 */
router.post('/pause/:queueName', catchAsync(async (req, res) => {
  const { queueName } = req.params;

  const queue = getQueueByName(queueName);
  if (!queue) {
    return res.status(404).json({
      status: 'error',
      message: 'Queue not found',
    });
  }

  await queue.pause();

  res.json({
    status: 'success',
    message: `Queue ${queueName} paused successfully`,
  });
}));

/**
 * @swagger
 * /admin/queues/resume/{queueName}:
 *   post:
 *     summary: Resume a paused queue
 *     tags: [Queue Management]
 */
router.post('/resume/:queueName', catchAsync(async (req, res) => {
  const { queueName } = req.params;

  const queue = getQueueByName(queueName);
  if (!queue) {
    return res.status(404).json({
      status: 'error',
      message: 'Queue not found',
    });
  }

  await queue.resume();

  res.json({
    status: 'success',
    message: `Queue ${queueName} resumed successfully`,
  });
}));

// Helper functions
async function getQueueStats(queue) {
  const [waiting, active, completed, failed, delayed, paused] = await Promise.all([
    queue.getWaiting(),
    queue.getActive(),
    queue.getCompleted(),
    queue.getFailed(),
    queue.getDelayed(),
    queue.isPaused(),
  ]);

  return {
    waiting: waiting.length,
    active: active.length,
    completed: completed.length,
    failed: failed.length,
    delayed: delayed.length,
    paused,
    name: queue.name,
  };
}

function getQueueByName(name) {
  const queues = {
    email: emailQueue,
    report: reportQueue,
    notification: notificationQueue,
  };
  return queues[name];
}

export default router; 