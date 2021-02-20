#!/usr/bin/env bash

echo "Running config generator"
python3 /home/ubuntu/generate-config.py
echo "Config updated!"
echo "reloading nginx config"
sudo systemctl reload nginx
echo "nginx config files reloaded"
