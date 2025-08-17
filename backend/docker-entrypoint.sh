#!/bin/sh
set -e

echo "🔄 Starting Attendkal Backend..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until node -e "
const { Client } = require('pg');
const client = new Client(process.env.DATABASE_URL);
client.connect()
  .then(() => { console.log('✅ Database is ready'); client.end(); })
  .catch(() => { console.log('❌ Database not ready, retrying...'); process.exit(1); });
" 2>/dev/null; do
  sleep 2
done

# Run database migrations
echo "🚀 Running database migrations..."
npx prisma migrate deploy

# Generate Prisma client (in case of any changes)
echo "🔧 Generating Prisma client..."
npx prisma generate

# Start the application
echo "✅ Starting application..."
exec node dist/server.js
