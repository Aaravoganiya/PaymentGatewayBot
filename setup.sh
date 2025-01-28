#!/bin/bash

sudo apt update
sudo apt install -y python3 python3-pip
pip3 install -r requirements.txt

read -p "Enter Telegram bot token: " token
echo "TELEGRAM_TOKEN=$token" > .env

sudo tee /etc/systemd/system/payment-bot.service > /dev/null <<EOL
[Unit]
Description=Payment Gateway Bot
After=network.target

[Service]
User=$USER
WorkingDirectory=$(pwd)
Environment="TELEGRAM_TOKEN=$token"
ExecStart=/usr/bin/python3 $(pwd)/bot.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable payment-bot
sudo systemctl start payment-bot
echo "Bot deployed! Use 'sudo systemctl status payment-bot' to check"
