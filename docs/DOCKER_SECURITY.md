# Docker Security Guide

## 🔒 Security Implementation

### Environment Variables Security
- **REQUIRED**: All sensitive values must be set via environment variables
- **NO DEFAULTS**: Removed weak default passwords from docker-compose.yml
- **VALIDATION**: Required environment variables will cause startup failure if missing

### Secure Configuration

#### 1. Generate Strong Secrets
```bash
# Generate strong database password
openssl rand -base64 32

# Generate JWT secret
openssl rand -base64 64

# Generate PgAdmin password
openssl rand -base64 24
```

#### 2. Environment Setup
```bash
# Copy and customize environment file
cp .env.example .env

# Edit .env with your secure values
# NEVER commit .env to version control
```

#### 3. Production Deployment
```bash
# Start with security profiles
docker-compose up -d --profile admin  # Include PgAdmin for admin access
docker-compose up -d                  # Production without PgAdmin
```

### Security Features Implemented

#### Docker Container Security
- ✅ Non-root user execution (attendkal:nodejs)
- ✅ Multi-stage builds to minimize attack surface
- ✅ Alpine Linux base images (smaller, fewer vulnerabilities)
- ✅ Specific UID/GID assignment (1001)
- ✅ Proper signal handling with dumb-init
- ✅ Security updates in container build
- ✅ Removed unnecessary packages and documentation

#### Network Security
- ✅ Isolated Docker network (attendkal-network)
- ✅ Service-to-service communication via container names
- ✅ No direct database exposure (internal network only)
- ✅ Configurable port exposure

#### Data Security
- ✅ Named volumes for data persistence
- ✅ PostgreSQL data directory security
- ✅ Environment variable validation
- ✅ No hardcoded secrets in images

#### Access Control
- ✅ PgAdmin behind profile flag (development only)
- ✅ Health checks for service reliability
- ✅ Restart policies for high availability
- ✅ Database connection validation

### Security Best Practices

#### Environment Management
1. **Separate environments**: Use different .env files for dev/staging/prod
2. **Secret rotation**: Regularly update JWT secrets and passwords
3. **Access logging**: Monitor PgAdmin access in development
4. **Network isolation**: Use Docker networks to isolate services

#### Production Hardening
```bash
# 1. Disable PgAdmin in production
docker-compose up -d  # No --profile admin

# 2. Use external secrets management
export JWT_SECRET=$(aws ssm get-parameter --name "/attendkal/jwt-secret" --with-decryption --query 'Parameter.Value' --output text)
export DB_PASSWORD=$(aws ssm get-parameter --name "/attendkal/db-password" --with-decryption --query 'Parameter.Value' --output text)

# 3. Run with security scanning
docker scan attendkal-backend:latest
docker scan attendkal-db:latest
```

#### Monitoring & Alerts
- Set up log monitoring for authentication failures
- Monitor database connection attempts
- Alert on container restart loops
- Track resource usage patterns

### Security Checklist

#### Pre-deployment
- [ ] Strong passwords generated (32+ characters)
- [ ] JWT secret generated (64+ characters)
- [ ] .env file configured and secured
- [ ] PgAdmin disabled for production
- [ ] Container images scanned for vulnerabilities
- [ ] Network policies configured

#### Post-deployment
- [ ] Health checks passing
- [ ] Logs showing successful authentication
- [ ] Database migrations applied
- [ ] No exposed debug endpoints
- [ ] SSL/TLS configured for external access
- [ ] Backup strategy implemented

### Incident Response
1. **Suspected breach**: Immediately rotate all secrets
2. **Container compromise**: Stop containers, rebuild from clean images
3. **Database access**: Change database passwords, review access logs
4. **Network intrusion**: Recreate Docker networks with new configuration

### Compliance Notes
- Passwords must meet organizational complexity requirements
- Audit logging should be enabled for production environments
- Data encryption at rest should be configured for sensitive data
- Regular security updates should be applied to base images

---

**Last Updated**: January 2024
**Security Review Required**: Quarterly
