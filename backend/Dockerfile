# Multi-stage build for production optimization
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Build application
RUN npm run build

# Production stage
FROM node:18-alpine AS runtime

# Install dumb-init and security updates
RUN apk add --no-cache dumb-init && \
    apk upgrade --no-cache

# Create app user with specific UID/GID for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S attendkal -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy package files with proper ownership
COPY --chown=attendkal:nodejs package*.json ./

# Install only production dependencies and clean cache
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Copy built application from builder stage with security hardening
COPY --from=builder --chown=attendkal:nodejs /app/dist ./dist
COPY --from=builder --chown=attendkal:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=attendkal:nodejs /app/prisma ./prisma

# Copy migration script with restricted permissions
COPY --chown=attendkal:nodejs docker-entrypoint.sh ./
RUN chmod 755 docker-entrypoint.sh

# Remove unnecessary packages and files for smaller attack surface
RUN rm -rf /usr/share/man/* /tmp/* /var/cache/apk/* /root/.npm /usr/lib/node_modules/npm/man/* /usr/lib/node_modules/npm/doc/*

# Switch to non-root user
USER attendkal

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["./docker-entrypoint.sh"]
