#!/bin/bash

# Local Development Script
# This script sets up and manages the local development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    log_info "Checking Docker status..."
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    log_success "Docker is running"
}

# Check if required directories exist
check_directories() {
    log_info "Checking project structure..."
    
    if [[ ! -d "backend" ]]; then
        log_error "Backend directory not found"
        exit 1
    fi
    
    if [[ ! -d "frontend" ]]; then
        log_error "Frontend directory not found"
        exit 1
    fi
    
    log_success "Project structure is valid"
}

# Install dependencies
install_deps() {
    log_info "Installing dependencies..."
    
    # Backend dependencies
    log_info "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
    
    # Frontend dependencies
    log_info "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
    
    log_success "All dependencies installed"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    # Backend tests
    log_info "Running backend tests..."
    cd backend
    npm test || log_warning "Backend tests failed or not configured"
    cd ..
    
    # Frontend tests
    log_info "Running frontend tests..."
    cd frontend
    npm test -- --coverage --silent --watchAll=false || log_warning "Frontend tests failed"
    cd ..
    
    log_success "Tests completed"
}

# Build applications
build_apps() {
    log_info "Building applications..."
    
    # Build frontend
    log_info "Building frontend..."
    cd frontend
    npm run build
    cd ..
    
    log_success "Applications built successfully"
}

# Start services with Docker Compose
start_services() {
    log_info "Starting services with Docker Compose..."
    
    # Stop any existing containers
    docker-compose down
    
    # Build and start services
    docker-compose up --build -d
    
    log_success "Services started"
    log_info "Waiting for services to be ready..."
    
    # Wait for services to be healthy
    sleep 30
    
    # Check service health
    check_services_health
}

# Check service health
check_services_health() {
    log_info "Checking service health..."
    
    # Check backend health
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        log_success "Backend service is healthy"
    else
        log_warning "Backend service is not responding"
    fi
    
    # Check frontend availability
    if curl -f http://localhost:3001 > /dev/null 2>&1; then
        log_success "Frontend service is healthy"
    else
        log_warning "Frontend service is not responding"
    fi
    
    # Check database
    if docker exec microservice_db mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        log_success "Database is healthy"
    else
        log_warning "Database is not responding"
    fi
}

# Stop services
stop_services() {
    log_info "Stopping services..."
    docker-compose down
    log_success "Services stopped"
}

# Clean up
cleanup() {
    log_info "Cleaning up..."
    
    # Remove containers and volumes
    docker-compose down -v
    
    # Remove unused Docker images
    docker image prune -f
    
    log_success "Cleanup completed"
}

# Show service status
show_status() {
    log_info "Service Status:"
    echo ""
    
    # Docker containers
    echo "Docker Containers:"
    docker-compose ps
    echo ""
    
    # Port mappings
    echo "Service URLs:"
    echo "  Backend API: http://localhost:3000"
    echo "  Frontend App: http://localhost:3001"
    echo "  Database: mongodb://localhost:27017"
    echo "  Health Check: http://localhost:3000/health"
    echo ""
    
    # Check if services are responding
    check_services_health
}

# Show logs
show_logs() {
    local service=$1
    if [[ -z "$service" ]]; then
        log_info "Showing logs for all services..."
        docker-compose logs -f
    else
        log_info "Showing logs for $service..."
        docker-compose logs -f "$service"
    fi
}

# Help function
show_help() {
    echo "Local Development Script"
    echo ""
    echo "Usage: ./scripts/dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Install dependencies and set up environment"
    echo "  start     - Start all services"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  status    - Show service status"
    echo "  logs      - Show logs (optional: specify service name)"
    echo "  test      - Run tests"
    echo "  build     - Build applications"
    echo "  cleanup   - Clean up containers and images"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./scripts/dev.sh setup"
    echo "  ./scripts/dev.sh start"
    echo "  ./scripts/dev.sh logs backend"
    echo ""
}

# Main execution
main() {
    case "${1:-help}" in
        setup)
            check_docker
            check_directories
            install_deps
            log_success "Setup completed! Run './scripts/dev.sh start' to start services."
            ;;
        start)
            check_docker
            start_services
            show_status
            ;;
        stop)
            stop_services
            ;;
        restart)
            check_docker
            stop_services
            start_services
            show_status
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "$2"
            ;;
        test)
            run_tests
            ;;
        build)
            build_apps
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
