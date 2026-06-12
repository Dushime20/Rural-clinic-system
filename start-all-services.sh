#!/bin/bash

# Start All Services Script
# This script starts backend, admin dashboard, and clinic dashboard concurrently
# Flutter app needs to be started separately: cd ai_health_companion && flutter run

echo "=========================================="
echo "Starting All Services"
echo "=========================================="
echo ""

# Check if required directories exist
if [ ! -d "ai_health_companion_backend" ]; then
    echo "❌ Error: ai_health_companion_backend directory not found"
    exit 1
fi

if [ ! -d "admin_dashboard" ]; then
    echo "❌ Error: admin_dashboard directory not found"
    exit 1
fi

if [ ! -d "clinic_dashboard" ]; then
    echo "❌ Error: clinic_dashboard directory not found"
    exit 1
fi

if [ ! -d "mbaza" ]; then
    echo "❌ Error: mbaza directory not found"
    exit 1
fi

# Function to kill all background processes on script exit
cleanup() {
    echo ""
    echo "=========================================="
    echo "Stopping all services..."
    echo "=========================================="
    kill $(jobs -p) 2>/dev/null
    wait
    echo "All services stopped."
    exit 0
}

# Trap Ctrl+C and call cleanup
trap cleanup INT TERM

echo "📦 Installing dependencies if needed..."
echo ""

# Install backend dependencies if needed
if [ ! -d "ai_health_companion_backend/node_modules" ]; then
    echo "Installing backend dependencies..."
    cd ai_health_companion_backend
    npm install
    cd ..
fi

# Install admin dashboard dependencies if needed
if [ ! -d "admin_dashboard/node_modules" ]; then
    echo "Installing admin dashboard dependencies..."
    cd admin_dashboard
    npm install
    cd ..
fi

# Install clinic dashboard dependencies if needed
if [ ! -d "clinic_dashboard/node_modules" ]; then
    echo "Installing clinic dashboard dependencies..."
    cd clinic_dashboard
    npm install
    cd ..
fi

echo ""
echo "=========================================="
echo "Starting services..."
echo "=========================================="
echo ""

# Start Mbaza Translation Service
echo "🚀 Starting Mbaza Translation Service (http://localhost:9000)..."
cd mbaza
python3 app_optimized.py > ../logs/mbaza.log 2>&1 &
MBAZA_PID=$!
cd ..
echo "   Mbaza PID: $MBAZA_PID"
echo "   Logs: logs/mbaza.log"
echo "   ⏳ Waiting for Mbaza NLP model to load (10-20 seconds)..."

# Wait for Mbaza to load model
sleep 15

# Start backend server
echo ""
echo "🚀 Starting Backend Server (http://localhost:3000)..."
cd ai_health_companion_backend
npm run dev > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "   Backend PID: $BACKEND_PID"
echo "   Logs: logs/backend.log"

# Wait a moment for backend to start
sleep 2

# Start admin dashboard
echo ""
echo "🚀 Starting Admin Dashboard (http://localhost:5173)..."
cd admin_dashboard
npm run dev > ../logs/admin-dashboard.log 2>&1 &
ADMIN_PID=$!
cd ..
echo "   Admin Dashboard PID: $ADMIN_PID"
echo "   Logs: logs/admin-dashboard.log"

# Start clinic dashboard
echo ""
echo "🚀 Starting Clinic Dashboard (http://localhost:5175)..."
cd clinic_dashboard
npm run dev > ../logs/clinic-dashboard.log 2>&1 &
CLINIC_PID=$!
cd ..
echo "   Clinic Dashboard PID: $CLINIC_PID"
echo "   Logs: logs/clinic-dashboard.log"

echo ""
echo "=========================================="
echo "✅ All services started successfully!"
echo "=========================================="
echo ""
echo "Services running:"
echo "  • Mbaza Translation: http://localhost:9000"
echo "  • Backend:           http://localhost:3000"
echo "  • Admin Dashboard:   http://localhost:5173"
echo "  • Clinic Dashboard:  http://localhost:5175"
echo ""
echo "To view logs:"
echo "  • Mbaza:            tail -f logs/mbaza.log"
echo "  • Backend:          tail -f logs/backend.log"
echo "  • Admin Dashboard:  tail -f logs/admin-dashboard.log"
echo "  • Clinic Dashboard: tail -f logs/clinic-dashboard.log"
echo ""
echo "To start Flutter app (in new terminal):"
echo "  cd ai_health_companion && flutter run"
echo ""
echo "Press Ctrl+C to stop all services"
echo "=========================================="

# Wait for all background processes
wait
