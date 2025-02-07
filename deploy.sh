#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

SCRIPT_NAME="
░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░      ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░      ░▒▓████████▓▒░▒▓██████▓▒░   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ 
"

echo -e "${CYAN}==============================================${NC}"
echo -e "${MAGENTA}${SCRIPT_NAME}${NC}"
echo -e "${CYAN}==============================================${NC}"
echo -e "${YELLOW}GitHub: https://github.com/funkyaditya${NC}"
echo -e "${CYAN}==============================================${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo).${NC}"
    exit 1
fi

install_nginx() {
    if ! command -v nginx &> /dev/null; then
        echo -e "${YELLOW}Installing Nginx...${NC}"
        apt update && apt install -y nginx
        echo -e "${GREEN}Nginx installed successfully.${NC}"
    else
        echo -e "${GREEN}Nginx is already installed.${NC}"
    fi
}

install_nginx

read -p "$(echo -e ${YELLOW}Enter the directory for the website: ${NC})" website_dir

if [ ! -d "$website_dir" ]; then
    echo -e "${RED}Error: Directory $website_dir does not exist.${NC}"
    exit 1
fi

read -p "$(echo -e ${YELLOW}Enter the port number to deploy the website on: ${NC})" port

if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo -e "${RED}Error: Port number must be a valid integer between 1 and 65535.${NC}"
    exit 1
fi

if sudo lsof -i:"$port" > /dev/null; then
    echo -e "${RED}Error: Port $port is already in use.${NC}"
    exit 1
fi

base_dir="/var/www/testwebsite"
new_website_dir="$base_dir"
counter=2
while [ -d "$new_website_dir" ]; do
    new_website_dir="${base_dir}${counter}"
    ((counter++))
done

sudo mkdir -p "$new_website_dir"
sudo cp -r "$website_dir/"* "$new_website_dir/"
sudo chown -R www-data:www-data "$new_website_dir"
sudo chmod -R 755 "$new_website_dir"

conf_file="/etc/nginx/sites-available/testwebsite"
conf_link="/etc/nginx/sites-enabled/testwebsite"

counter=2
while [ -f "$conf_file" ] || [ -L "$conf_link" ]; do
    conf_file="/etc/nginx/sites-available/testwebsite${counter}"
    conf_link="/etc/nginx/sites-enabled/testwebsite${counter}"
    ((counter++))
done

conf_block="
server {
    listen $port;
    server_name localhost;
    root \"$new_website_dir\";
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
"

echo "$conf_block" | sudo tee "$conf_file" > /dev/null
sudo ln -s "$conf_file" "$conf_link"

if ! sudo nginx -t; then
    echo -e "${RED}Nginx configuration failed. Please check the config file.${NC}"
    exit 1
fi

sudo systemctl reload nginx

if ! sudo ufw status | grep -q "$port"; then
    sudo ufw allow "$port"
fi

echo -e "${GREEN}Website deployed successfully at $new_website_dir on port $port.${NC}"
echo -e "${CYAN}==============================================${NC}"
