#!/bin/bash


set -e

echo "🚀 Starting Monitoring Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Check if Docker Compose is installed
check_docker_compose() {
    print_status "Checking Docker Compose installation..."
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker Compose is available"
}

# Clean up existing containers and volumes
cleanup() {
    print_status "Cleaning up existing containers and volumes..."
    
    # Stop and remove containers
    docker-compose down --volumes --remove-orphans 2>/dev/null || docker compose down --volumes --remove-orphans 2>/dev/null || true
    
    # Remove unused images
    docker image prune -f
    
    print_success "Cleanup completed"
}

# Build and start services
deploy() {
    print_status "Building and starting monitoring services..."
    
    # Build and start all services
    if command -v docker-compose &> /dev/null; then
        docker-compose up --build -d
    else
        docker compose up --build -d
    fi
    
    print_success "All services are starting up..."
}

# Wait for services to be healthy
wait_for_services() {
    print_status "Waiting for services to be healthy..."
    
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Health check attempt $attempt/$max_attempts..."
        
        # Check if all services are running
        local running_services=$(docker ps --filter "name=monitoring" --format "table {{.Names}}" | grep -v NAMES | wc -l)
        
        if [ "$running_services" -ge 10 ]; then
            print_success "All services are running!"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_warning "Some services may still be starting up. Check logs if needed."
            break
        fi
        
        sleep 5
        ((attempt++))
    done
}

# Display service status
show_status() {
    print_status "Service Status:"
    echo ""
    
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi
    
    echo ""
    print_status "Service URLs:"
    echo "🔴 <ip>:3000"
    echo "🔴 <ip>:9090"
    echo "🔴 <ip>:9100"
    echo "🔴 <ip>:9093"
    echo ""
    echo ""
    echo ""
    echo ""
}

# Show logs
show_logs() {
    print_status "Recent logs from all services:"
    echo ""
    
    if command -v docker-compose &> /dev/null; then
        docker-compose logs --tail=10
    else
        docker compose logs --tail=10
    fi
}

# Main deployment function
main() {
    echo "🛒 Monitoring services Deployment"
    echo "===================================="
    echo ""
    
    check_docker
    check_docker_compose
    
    # Ask user if they want to clean up first
    read -p "Do you want to clean up existing containers? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    fi
    
    deploy
    wait_for_services
    show_status
    
    echo ""
    print_success "🎉 deployment completed!"
    echo ""
    print_status "Next steps:"
    echo "1. View logs: ./deploy-docker.sh logs"
    echo "2. Stop services: ./deploy-docker.sh stop"
    echo ""
}

# Handle script arguments
case "${1:-}" in
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "stop")
        print_status "Stopping all services..."
        if command -v docker-compose &> /dev/null; then
            docker-compose down
        else
            docker compose down
        fi
        print_success "All services stopped"
        ;;
    "clean")
        cleanup
        ;;
    "restart")
        cleanup
        deploy
        wait_for_services
        show_status
        ;;
    *)
        main
        ;;
esac
