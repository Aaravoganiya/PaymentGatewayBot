#!/bin/bash

sudo apt update
sudo apt install -y python3 python3-pip python3-venv git

read -p "Enter Telegram bot token: " token

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Create .env file
echo "TELEGRAM_TOKEN=$token" > .env

# Create systemd service file
sudo tee /etc/systemd/system/payment-bot.service > /dev/null <<EOL
[Unit]
Description=Payment Gateway Bot
After=network.target

[Service]
User=$USER
WorkingDirectory=$(pwd)
Environment="TELEGRAM_TOKEN=$token"
ExecStart=$(pwd)/venv/bin/python $(pwd)/bot.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload and enable service
sudo systemctl daemon-reload
sudo systemctl enable payment-bot
sudo systemctl start payment-bot

echo "Bot deployed! Use 'sudo systemctl status payment-bot' to check"
