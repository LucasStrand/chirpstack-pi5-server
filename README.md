# ChirpStack LoRaWAN Gateway & Server for Raspberry Pi 5

This project provides a complete ChirpStack LoRaWAN network server and gateway setup optimized for Raspberry Pi 5. It uses Docker containers to run all components, making it easy to deploy and manage.

## Features

- **Complete LoRaWAN Stack**: Includes ChirpStack Network Server, Gateway Bridge, and all supporting services
- **ARM64 Optimized**: Specifically designed for Raspberry Pi 5's ARM64 architecture
- **Docker-Based**: Easy deployment and management using Docker Compose
- **Production-Ready**: Includes PostgreSQL, Redis, and MQTT broker for a robust setup
- **Multi-Region Support**: Configured for EU868, US915, and other common LoRaWAN regions

## Components

- **ChirpStack Network Server v4**: The core LoRaWAN network server
- **ChirpStack Gateway Bridge v4**: Converts Semtech UDP protocol to MQTT
- **PostgreSQL 16**: Database for persistent data storage
- **Redis 7**: In-memory data store for caching and temporary data
- **Eclipse Mosquitto**: MQTT broker for communication
- **ChirpStack REST API**: Optional REST API interface

## Prerequisites

- Raspberry Pi 5 (8GB or 16GB recommended)
- Raspberry Pi OS 64-bit (Debian Bookworm based)
- Internet connection for downloading Docker images
- LoRa gateway hardware (e.g., RAK2245, Seeed WM1302, etc.)

## Quick Start

1. **Clone this repository** to your Raspberry Pi 5:
   ```bash
   git clone https://github.com/yourusername/chirpstack-pi5-server.git
   cd chirpstack-pi5-server
   ```

2. **Make the setup script executable**:
   ```bash
   chmod +x setup.sh
   ```

3. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

   This script will:
   - Install Docker and Docker Compose (if not already installed)
   - Create necessary directories
   - Generate secure passwords
   - Pull all Docker images
   - Start all services

4. **Access ChirpStack**:
   - Open your browser and navigate to: `http://<your-pi-ip>:8080`
   - Default username: `admin`
   - Default password: `admin`
   - **Important**: Change the default password immediately!

## Configuration

### Gateway Configuration

Your LoRa gateway should be configured to forward packets to:
- **Server address**: Your Raspberry Pi's IP address
- **Server port**: 1700 (UDP)

### Region Configuration

The default configuration supports multiple regions. To change the primary region, edit `config/chirpstack/chirpstack.toml` and `config/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml`.

Common regions:
- EU868 (Europe)
- US915 (North America)
- AS923 (Asia)
- AU915 (Australia)

### Security

1. **Change default passwords**:
   - ChirpStack web interface admin password
   - PostgreSQL password in `docker-compose.yml` and `config/chirpstack/chirpstack.toml`
   - Add MQTT authentication (see `config/mosquitto/mosquitto.conf`)

2. **Enable HTTPS** (recommended for production):
   - Use a reverse proxy like nginx or Caddy
   - Obtain SSL certificates (e.g., Let's Encrypt)

## Directory Structure

```
pi5-lora-server/
├── docker-compose.yml          # Main Docker Compose configuration
├── setup.sh                    # Automated setup script
├── README.md                   # This file
├── config/                     # Configuration files
│   ├── chirpstack/            # ChirpStack server config
│   ├── chirpstack-gateway-bridge/  # Gateway bridge config
│   ├── mosquitto/             # MQTT broker config
│   └── chirpstack-rest-api/   # REST API config
└── data/                      # Persistent data (auto-created)
    ├── postgresql/            # Database files
    ├── redis/                 # Redis persistence
    └── mosquitto/             # MQTT persistence
```

## Management Commands

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f chirpstack
```

### Stop services
```bash
docker-compose down
```

### Start services
```bash
docker-compose up -d
```

### Restart a service
```bash
docker-compose restart chirpstack
```

### Update services
```bash
docker-compose pull
docker-compose up -d
```

### Backup data
```bash
# Stop services
docker-compose down

# Backup data directory
tar -czf chirpstack-backup-$(date +%Y%m%d).tar.gz data/

# Restart services
docker-compose up -d
```

## Troubleshooting

### Gateway not connecting
1. Check firewall settings - ensure UDP port 1700 is open
2. Verify gateway configuration points to correct IP
3. Check logs: `docker-compose logs -f chirpstack-gateway-bridge`

### Cannot access web interface
1. Ensure port 8080 is not blocked
2. Check ChirpStack is running: `docker-compose ps`
3. Review logs: `docker-compose logs -f chirpstack`

### Database connection errors
1. Ensure PostgreSQL is running: `docker-compose ps postgres`
2. Check PostgreSQL logs: `docker-compose logs -f postgres`
3. Verify credentials match in all configuration files

## Performance Optimization

For Raspberry Pi 5:
1. Use a fast SD card (Class 10/A2) or SSD via USB
2. Ensure adequate cooling (official Active Cooler recommended)
3. Consider overclocking for better performance (use `raspi-config`)

## Adding Devices

1. Log into ChirpStack web interface
2. Create a Device Profile (or use existing)
3. Create an Application
4. Add devices with their DevEUI, AppKey, etc.
5. Configure integrations (HTTP, MQTT, etc.)

## Integration with Home Assistant

To integrate with Home Assistant:
1. Use MQTT integration in Home Assistant
2. Configure Home Assistant to connect to Mosquitto on port 1883
3. Subscribe to device topics: `application/+/device/+/event/up`

## Support and Documentation

- ChirpStack Documentation: https://www.chirpstack.io/
- ChirpStack Forum: https://forum.chirpstack.io/
- Docker Documentation: https://docs.docker.com/

## License

This setup is provided as-is under the MIT License. ChirpStack components are licensed under their respective licenses.

## Contributing

Contributions are welcome! Please submit pull requests or issues on GitHub.

## Acknowledgments

- ChirpStack project by Orne Brocaar
- Docker community for ARM64 support
- Raspberry Pi Foundation

---

**Note**: This is an unofficial setup guide. For official ChirpStack support, please refer to the official documentation. 