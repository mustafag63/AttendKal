import prometheus from 'prom-client';

// Create a Registry to register the metrics
const register = new prometheus.Registry();

// Add default metrics (CPU, memory, etc.)
prometheus.collectDefaultMetrics({ register });

// Custom metrics for our API
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10],
});

const httpRequestsTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
});

const databaseQueryDuration = new prometheus.Histogram({
  name: 'database_query_duration_seconds',
  help: 'Duration of database queries in seconds',
  labelNames: ['operation', 'table'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
});

const authenticationAttempts = new prometheus.Counter({
  name: 'authentication_attempts_total',
  help: 'Total authentication attempts',
  labelNames: ['status', 'method'],
});

const attendanceRecords = new prometheus.Counter({
  name: 'attendance_records_total',
  help: 'Total attendance records created',
  labelNames: ['status', 'course_id'],
});

const courseActivities = new prometheus.Counter({
  name: 'course_activities_total',
  help: 'Total course activities',
  labelNames: ['action', 'course_id'],
});

// Register all metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(activeConnections);
register.registerMetric(databaseQueryDuration);
register.registerMetric(authenticationAttempts);
register.registerMetric(attendanceRecords);
register.registerMetric(courseActivities);

// Middleware to collect HTTP metrics
export const metricsMiddleware = (req, res, next) => {
  const start = Date.now();

  // Increment active connections
  activeConnections.inc();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;

    // Record request duration
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);

    // Increment request counter
    httpRequestsTotal
      .labels(req.method, route, res.statusCode)
      .inc();

    // Decrement active connections
    activeConnections.dec();
  });

  next();
};

// Metrics endpoint
export const metricsEndpoint = async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    const metrics = await register.metrics();
    res.end(metrics);
  } catch (error) {
    res.status(500).end(error.message);
  }
};

// Helper functions to record custom metrics
export const recordDatabaseQuery = (operation, table, duration) => {
  databaseQueryDuration
    .labels(operation, table)
    .observe(duration);
};

export const recordAuthAttempt = (status, method) => {
  authenticationAttempts
    .labels(status, method)
    .inc();
};

export const recordAttendance = (status, courseId) => {
  attendanceRecords
    .labels(status, courseId)
    .inc();
};

export const recordCourseActivity = (action, courseId) => {
  courseActivities
    .labels(action, courseId)
    .inc();
};

export { register }; 