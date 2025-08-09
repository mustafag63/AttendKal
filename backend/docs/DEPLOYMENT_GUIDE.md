# AttendKal Backend Deployment Guide

## 🚀 Production Deployment

### Prerequisites

- Node.js 18.0.0 or higher
- PostgreSQL 12.0 or higher
- Redis (optional, for caching and queues)
- Docker (optional, for containerized deployment)

### Environment Setup

1. **Copy environment variables:**
   ```bash
   cp .env.example .env
   ```

2. **Configure required variables:**
   ```env
   # Database
   DATABASE_URL=postgresql://username:password@localhost:5432/attendkal_prod

   # JWT Secrets (Generate strong 32+ character secrets)
   JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
   JWT_REFRESH_SECRET=your-super-secret-jwt-refresh-key-minimum-32-characters

   # Production settings
   NODE_ENV=production
   PORT=3000

   # Security
   CORS_ORIGIN=https://yourdomain.com
   BCRYPT_ROUNDS=12

   # Email configuration
   EMAIL_HOST=smtp.your-provider.com
   EMAIL_PORT=587
   EMAIL_USER=your-email@domain.com
   EMAIL_PASSWORD=your-app-password
   ```

### Database Setup

1. **Create database:**
   ```bash
   createdb attendkal_prod
   ```

2. **Run migrations:**
   ```bash
   npm run prisma:migrate:deploy
   ```

3. **Generate Prisma client:**
   ```bash
   npm run prisma:gen
   ```

### Application Deployment

#### Option 1: Direct Deployment

1. **Install dependencies:**
   ```bash
   npm ci --only=production
   ```

2. **Build application:**
   ```bash
   npm run build
   ```

3. **Start with PM2:**
   ```bash
   npm install -g pm2
   pm2 start ecosystem.config.cjs --env production
   ```

#### Option 2: Docker Deployment

1. **Build Docker image:**
   ```bash
   docker build -t attendkal-backend .
   ```

2. **Run with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

### SSL/HTTPS Setup

#### Using Let's Encrypt with Nginx

1. **Install Nginx:**
   ```bash
   sudo apt install nginx
   ```

2. **Configure Nginx:**
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com;
       return 301 https://$server_name$request_uri;
   }

   server {
       listen 443 ssl http2;
       server_name yourdomain.com;

       ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

3. **Get SSL certificate:**
   ```bash
   sudo certbot --nginx -d yourdomain.com
   ```

### Security Hardening

1. **Firewall configuration:**
   ```bash
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw allow 443
   sudo ufw enable
   ```

2. **Database security:**
   - Use strong passwords
   - Restrict database access to application server
   - Enable SSL connections

3. **Application security:**
   - Keep dependencies updated
   - Use HTTPS only
   - Implement proper CORS policies
   - Monitor for security vulnerabilities

### Monitoring Setup

#### Prometheus + Grafana

1. **Start monitoring stack:**
   ```bash
   cd monitoring/
   docker-compose up -d
   ```

2. **Access dashboards:**
   - Grafana: http://localhost:3001
   - Prometheus: http://localhost:9090

#### Log Management

1. **Configure log rotation:**
   ```bash
   sudo nano /etc/logrotate.d/attendkal
   ```

   ```
   /path/to/attendkal/logs/*.log {
       daily
       missingok
       rotate 14
       compress
       notifempty
       copytruncate
   }
   ```

### Backup Strategy

#### Database Backup

1. **Automated daily backups:**
   ```bash
   #!/bin/bash
   # backup-db.sh
   DATE=$(date +%Y%m%d_%H%M%S)
   pg_dump $DATABASE_URL > "backup_${DATE}.sql"
   aws s3 cp "backup_${DATE}.sql" s3://your-backup-bucket/
   rm "backup_${DATE}.sql"
   ```

2. **Schedule with cron:**
   ```bash
   0 2 * * * /path/to/backup-db.sh
   ```

#### File Backup

```bash
# Backup uploads and logs
tar -czf backup_files_$(date +%Y%m%d).tar.gz uploads/ logs/
```

### Performance Optimization

1. **Database optimization:**
   ```sql
   -- Optimize frequently queried tables
   CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_attendance_user_date 
   ON "Attendance" ("userId", "date");
   
   CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_course_user_active 
   ON "Course" ("userId", "isActive");
   ```

2. **Caching with Redis:**
   ```bash
   # Install Redis
   sudo apt install redis-server
   
   # Configure Redis
   sudo nano /etc/redis/redis.conf
   # Set maxmemory and eviction policy
   ```

3. **Process management:**
   ```javascript
   // ecosystem.config.cjs
   module.exports = {
     apps: [{
       name: 'attendkal-api',
       script: 'src/server.js',
       instances: 'max',
       exec_mode: 'cluster',
       env_production: {
         NODE_ENV: 'production',
         PORT: 3000
       }
     }]
   };
   ```

### Health Checks

1. **Endpoint monitoring:**
   ```bash
   curl -f http://localhost:3000/health || exit 1
   ```

2. **Database connectivity:**
   ```bash
   curl -f http://localhost:3000/health/db || exit 1
   ```

3. **Service monitoring with Uptime Robot or similar**

### Troubleshooting

#### Common Issues

1. **Database connection errors:**
   ```bash
   # Check database status
   sudo systemctl status postgresql
   
   # Check connection
   psql $DATABASE_URL -c "SELECT 1;"
   ```

2. **Memory issues:**
   ```bash
   # Monitor memory usage
   htop
   
   # Check Node.js heap
   node --max-old-space-size=4096 src/server.js
   ```

3. **Port conflicts:**
   ```bash
   # Check port usage
   sudo netstat -tulpn | grep :3000
   
   # Kill process if needed
   sudo kill -9 <PID>
   ```

#### Log Analysis

```bash
# View recent logs
tail -f logs/app.log

# Search for errors
grep -i error logs/app.log

# Monitor API responses
grep "HTTP" logs/app.log | tail -20
```

### Scaling

#### Horizontal Scaling

1. **Load balancer setup:**
   ```nginx
   upstream attendkal_backend {
       server 127.0.0.1:3000;
       server 127.0.0.1:3001;
       server 127.0.0.1:3002;
   }
   ```

2. **Database read replicas:**
   - Configure PostgreSQL streaming replication
   - Update application to use read replicas for queries

#### Vertical Scaling

1. **Increase server resources:**
   - CPU: Add more cores
   - RAM: Increase memory allocation
   - Storage: Use faster SSD storage

2. **Database optimization:**
   - Tune PostgreSQL configuration
   - Implement connection pooling
   - Optimize queries and indexes

### Maintenance

#### Regular Tasks

1. **Weekly:**
   - Review logs for errors
   - Check disk space
   - Verify backups

2. **Monthly:**
   - Update dependencies
   - Review security patches
   - Performance analysis

3. **Quarterly:**
   - Security audit
   - Disaster recovery testing
   - Capacity planning

#### Update Procedure

1. **Backup before updates:**
   ```bash
   ./backup-db.sh
   tar -czf app_backup.tar.gz src/ package.json
   ```

2. **Update dependencies:**
   ```bash
   npm audit fix
   npm update
   ```

3. **Test and deploy:**
   ```bash
   npm test
   pm2 restart attendkal-api
   ```

### Support

For deployment issues:
- Check logs: `tail -f logs/app.log`
- Health check: `curl http://localhost:3000/health`
- Database status: `npm run prisma:studio`
- Metrics: `curl http://localhost:3000/metrics` 