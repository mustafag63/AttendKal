# Environment Setup Instructions

## Backend (.env)

Create `backend/.env` with:

```bash
NODE_ENV=development
PORT=3000

# Dev DB (SQLite)
DATABASE_URL="file:./prisma/dev.db"

# JWT
JWT_SECRET=dev-secret
JWT_REFRESH_SECRET=dev-refresh
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d

# CORS: admin panel dev portu
CORS_ORIGIN=http://localhost:3001,http://127.0.0.1:3001

LOG_LEVEL=info
```

## Admin Panel (.env.local)

Create `admin-panel/.env.local` with:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
```

## Quick Setup Commands

```bash
# Backend environment
cd backend
cat > .env << 'EOF'
NODE_ENV=development
PORT=3000
DATABASE_URL="file:./prisma/dev.db"
JWT_SECRET=dev-secret
JWT_REFRESH_SECRET=dev-refresh
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d
CORS_ORIGIN=http://localhost:3001,http://127.0.0.1:3001
LOG_LEVEL=info
EOF

# Admin Panel environment
cd ../admin-panel
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
EOF
```

## Development Startup

```bash
# Terminal 1 - Backend (Port 3000)
cd backend
pnpm i
pnpm prisma:gen
pnpm prisma:push
pnpm seed:admin
pnpm dev

# Terminal 2 - Admin Panel (Port 3001)
cd admin-panel
npm i
npm run dev
```

Login: admin@attendkal.com / Admin123! 