#!/bin/bash

# Script to start both backend and frontend services

echo "🚀 Starting Microservice Application"
echo "=================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Function to start backend
start_backend() {
    echo "📡 Starting Backend Service on port 3000..."
    cd backend
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing backend dependencies..."
        npm install
    fi
    npm start &
    BACKEND_PID=$!
    echo "✅ Backend started with PID: $BACKEND_PID"
    cd ..
}

# Function to start frontend
start_frontend() {
    echo "💻 Starting Frontend Service on port 3001..."
    cd frontend
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing frontend dependencies..."
        npm install
    fi
    npm start &
    FRONTEND_PID=$!
    echo "✅ Frontend started with PID: $FRONTEND_PID"
    cd ..
}

# Function to cleanup processes on exit
cleanup() {
    echo -e "\n🛑 Stopping services..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        echo "🔴 Backend service stopped"
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        echo "🔴 Frontend service stopped"
    fi
    exit 0
}

# Set up trap to cleanup on script exit
trap cleanup INT TERM EXIT

# Start services
start_backend
sleep 2  # Give backend time to start
start_frontend

echo ""
echo "🎉 Services are starting up!"
echo "📡 Backend API: http://localhost:3000"
echo "💻 Frontend App: http://localhost:3001"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for processes to finish
wait
