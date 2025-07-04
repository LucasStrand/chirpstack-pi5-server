#!/bin/bash

# ChirpStack setup script for Raspberry Pi 5
# This script sets up ChirpStack with all necessary components

set -e

echo "========================================="
echo "ChirpStack Setup for Raspberry Pi 5"
echo "========================================="

# Check if running on ARM64
if [ "$(uname -m)" != "aarch64" ]; then
    echo "Warning: This script is designed for ARM64 architecture (Raspberry Pi 5)"
    echo "Current architecture: $(uname -m)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed. Please log out and log back in for group changes to take effect."
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p config/{mosquitto,chirpstack,chirpstack-gateway-bridge,chirpstack-rest-api}
mkdir -p data/{postgresql,redis,mosquitto/log,chirpstack-upload}

# Set permissions
chmod 755 config data
chmod -R 755 config/*
chmod -R 755 data/*

# Generate random secret for ChirpStack
SECRET=$(openssl rand -base64 32)
echo "Generated API secret: $SECRET"

# Update ChirpStack configuration with the secret
if [ -f "config/chirpstack/chirpstack.toml" ]; then
    sed -i "s|you-must-replace-this-with-a-random-string|$SECRET|g" config/chirpstack/chirpstack.toml
    echo "Updated ChirpStack configuration with generated secret"
fi

# Create .env file for environment variables
cat > .env << EOF
# ChirpStack Environment Variables
CHIRPSTACK_API_SECRET=$SECRET
POSTGRES_PASSWORD=chirpstack_postgres_pass
REGION=EU868
EOF

echo "Created .env file with environment variables"

# Pull Docker images
echo "Pulling Docker images..."
docker-compose pull

# Start services
echo "Starting ChirpStack services..."
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Check service status
echo "Checking service status..."
docker-compose ps

echo "========================================="
echo "ChirpStack setup complete!"
echo "========================================="
echo ""
echo "Access ChirpStack at: http://$(hostname -I | awk '{print $1}'):8080"
echo "Default username: admin"
echo "Default password: admin"
echo ""
echo "IMPORTANT: Change the default password immediately!"
echo ""
echo "Gateway should connect to UDP port 1700"
echo "MQTT broker is available on port 1883"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop services: docker-compose down"
echo "To restart services: docker-compose restart"
echo "" 