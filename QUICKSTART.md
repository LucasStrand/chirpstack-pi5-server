# ChirpStack on Raspberry Pi 5 - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Raspberry Pi 5 with 64-bit Raspberry Pi OS
- Internet connection
- LoRa gateway hardware (RAK, Seeed, etc.)

### Installation

1. **Clone the repository** to your Pi:
   ```bash
   git clone https://github.com/yourusername/chirpstack-pi5-server.git
   cd chirpstack-pi5-server
   ```

2. **Run the automated setup**:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Wait for installation** (about 5-10 minutes)

4. **Access ChirpStack**:
   - Open browser: `http://<your-pi-ip>:8080`
   - Username: `admin`
   - Password: `admin`
   - **Change password immediately!**

### Configure Your Gateway

1. **Run the gateway helper**:
   ```bash
   chmod +x configure-gateway.sh
   ./configure-gateway.sh
   ```

2. **Follow the prompts** for your specific gateway hardware

3. **Configure your gateway** to send data to:
   - Server: Your Pi's IP address
   - Port: 1700 (UDP)

### Quick Test

1. **Check services are running**:
   ```bash
   docker-compose ps
   ```

2. **View gateway connection logs**:
   ```bash
   docker-compose logs -f chirpstack-gateway-bridge
   ```

3. **Add a test device** in the ChirpStack web UI:
   - Go to Applications → Create New
   - Go to Devices → Add Device
   - Enter DevEUI, AppKey, etc.

## 🛠️ Common Tasks

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f chirpstack
```

### Restart Services
```bash
docker-compose restart
```

### Stop Everything
```bash
docker-compose down
```

### Create Backup
```bash
chmod +x backup-restore.sh
./backup-restore.sh
# Select option 1
```

## 📊 Service Ports

| Service | Port | Description |
|---------|------|-------------|
| ChirpStack UI | 8080 | Web interface |
| Gateway Bridge | 1700/UDP | Gateway connections |
| MQTT Broker | 1883 | MQTT communications |
| REST API | 8090 | API access |

## 🔧 Troubleshooting

### Gateway Not Connecting?
- Check firewall: `sudo ufw allow 1700/udp`
- Verify gateway config points to Pi's IP
- Check logs: `docker-compose logs -f chirpstack-gateway-bridge`

### Can't Access Web UI?
- Check IP address: `hostname -I`
- Ensure port 8080 is open
- Verify ChirpStack is running: `docker-compose ps`

### Services Won't Start?
- Check Docker is installed: `docker --version`
- Ensure you're in the correct directory
- Try: `docker-compose down && docker-compose up -d`

## 📚 Next Steps

1. **Secure your installation**:
   - Change all default passwords
   - Configure firewall rules
   - Enable HTTPS (see README.md)

2. **Add your devices**:
   - Create device profiles
   - Register your LoRa devices
   - Set up integrations

3. **Monitor and maintain**:
   - Set up regular backups
   - Monitor system resources
   - Keep services updated

## 🆘 Getting Help

- ChirpStack Docs: https://www.chirpstack.io/
- ChirpStack Forum: https://forum.chirpstack.io/
- Project Issues: [GitHub Issues]

---

**Pro Tip**: Run `./backup-restore.sh` regularly to backup your data! 