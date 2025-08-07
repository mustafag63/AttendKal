#!/bin/bash

# AttendKal Development Startup Script
echo "🚀 Starting AttendKal Development Environment..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18+ to continue.${NC}"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter to continue.${NC}"
    exit 1
fi

# Check if PostgreSQL is running
if ! pg_isready &> /dev/null; then
    echo -e "${YELLOW}⚠️  PostgreSQL doesn't seem to be running. Please start PostgreSQL first.${NC}"
    echo -e "${BLUE}💡 You can start PostgreSQL with: brew services start postgresql${NC}"
fi

echo -e "${BLUE}📋 Checking dependencies...${NC}"

# Backend setup
echo -e "${BLUE}🔧 Setting up backend...${NC}"
cd backend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing backend dependencies...${NC}"
    npm install
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚙️  .env file not found. Please create one based on .env.example${NC}"
    echo -e "${BLUE}📝 Example .env configuration:${NC}"
    echo "DATABASE_URL=\"postgresql://username:password@localhost:5432/attendkal_db\""
    echo "JWT_SECRET=\"your-super-secret-jwt-key\""
    echo "JWT_REFRESH_SECRET=\"your-super-secret-refresh-key\""
    echo "NODE_ENV=\"development\""
    echo "PORT=3000"
fi

# Generate Prisma client
echo -e "${BLUE}🔄 Generating Prisma client...${NC}"
npm run db:generate

echo -e "${GREEN}✅ Backend setup complete!${NC}"

# Flutter setup
echo -e "${BLUE}🔧 Setting up Flutter app...${NC}"
cd ../

# Check if Flutter dependencies are installed
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get

echo -e "${GREEN}✅ Flutter setup complete!${NC}"

# Start services
echo -e "${BLUE}🚀 Starting services...${NC}"

# Function to handle cleanup
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down services...${NC}"
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

# Trap cleanup function on script exit
trap cleanup SIGINT SIGTERM

# Start backend
echo -e "${BLUE}🖥️  Starting backend server...${NC}"
cd backend
npm run dev &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Start Flutter app
echo -e "${BLUE}📱 Starting Flutter app...${NC}"
cd ../
flutter run -d chrome &
FRONTEND_PID=$!

echo -e "${GREEN}🎉 AttendKal development environment is running!${NC}"
echo -e "${BLUE}📊 Backend API: http://localhost:3000${NC}"
echo -e "${BLUE}📚 API Documentation: http://localhost:3000/api-docs${NC}"
echo -e "${BLUE}❤️  Health Check: http://localhost:3000/health${NC}"
echo -e "${BLUE}📱 Flutter App: Running in Chrome${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"

# Wait for user to terminate
wait 