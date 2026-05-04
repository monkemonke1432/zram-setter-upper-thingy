#!/bin/bash
set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

# Install zram-generator
echo "Installing zram-generator..."
pacman -S zram-generator --noconfirm

# Create necessary configuration directory
echo "Creating configuration folders..."
mkdir -p /etc/systemd/zram-generator.conf.d

# Write zram configuration
echo "Writing zram configuration..."
cat > /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# Reload systemd, start and enable service
echo "Starting and enabling zram service..."
systemctl daemon-reload
systemctl start systemd-zram-setup@zram0.service
systemctl enable systemd-zram-setup@zram0.service

# Verify setup
echo -e "\nVerifying zram setup..."
echo "Zram devices:"
zramctl
echo -e "\nActive swap:"
swapon --show

echo -e "\nZram setup complete!"
