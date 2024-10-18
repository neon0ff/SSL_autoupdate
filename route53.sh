#!/bin/bash

# Переменные
DOMAIN=""
EMAIL=""
AWS_ACCESS_KEY=""
AWS_SECRET_KEY=""
AWS_REGION=""

# Функция для запроса ввода
read_input() {
    read -p "Введите домен для сертификата (example.com): " DOMAIN
    if [ -z "$EMAIL" ]; then
        read -p "Введите email для уведомлений Let's Encrypt (или оставьте пустым): " EMAIL
    fi
    read -p "Введите AWS Access Key ID: " AWS_ACCESS_KEY
    read -p "Введите AWS Secret Access Key: " AWS_SECRET_KEY
    read -p "Введите регион AWS (например, eu-north-1): " AWS_REGION
}

# Обновляем пакеты
echo "Обновляем пакеты..."
sudo apt update -y

# Спрашиваем, нужен ли NGINX
read -p "Хотите ли вы установить и настроить NGINX? (y/n): " NGINX_SETUP
if [[ "$NGINX_SETUP" == "y" || "$NGINX_SETUP" == "Y" ]]; then
    # Устанавливаем NGINX если он не установлен
    if ! dpkg -l | grep -q nginx; then
        echo "Устанавливаем NGINX..."
        sudo apt install -y nginx
    fi
fi

# Устанавливаем Snap, если он не установлен
if ! command -v snap &> /dev/null; then
    echo "Устанавливаем Snap..."
    sudo apt install -y snapd
fi

# Устанавливаем Certbot через Snap
echo "Устанавливаем Certbot..."
sudo snap install --classic certbot

# Создаем символическую ссылку для Certbot
echo "Создаем символическую ссылку для Certbot..."
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Разрешаем Certbot работать с плагинами от root
echo "Настраиваем Certbot для корректной работы..."
sudo snap set certbot trust-plugin-with-root=ok

# Устанавливаем Certbot DNS agent для AWS Route 53
echo "Устанавливаем Certbot DNS Route53 плагин..."
sudo snap install certbot-dns-route53

# Устанавливаем AWS CLI
echo "Устанавливаем AWS CLI..."
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip

# Проверяем установку AWS CLI
aws --version

# Настраиваем AWS CLI
echo "Настраиваем AWS CLI..."
aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set region "$AWS_REGION"

# Запрашиваем ввод домена, email и региона, если они не переданы через переменные
if [ -z "$DOMAIN" ] || [ -z "$AWS_REGION" ]; then
    read_input
fi

# Получаем SSL-сертификат через DNS Route 53
if [ -z "$EMAIL" ]; then
    # Если email не указан, вызываем certbot без email-флага
    echo "Запрашиваем SSL-сертификат для домена $DOMAIN без email..."
    sudo certbot certonly --dns-route53 -d "$DOMAIN" --agree-tos --no-eff-email
else
    # Если email указан, добавляем email-флаг
    echo "Запрашиваем SSL-сертификат для домена $DOMAIN с email $EMAIL..."
    sudo certbot certonly --dns-route53 -d "$DOMAIN" --email "$EMAIL" --agree-tos --no-eff-email
fi

# Настройка сертификатов через NGINX (если выбран)
if [[ "$NGINX_SETUP" == "y" || "$NGINX_SETUP" == "Y" ]]; then
    echo "Настройка сертификатов через NGINX..."
    sudo certbot --nginx -d "$DOMAIN"
    
    # Спрашиваем, нужно ли добавить принудительное обновление в cron с перезапуском NGINX
    read -p "Хотите ли вы добавить обновление сертификатов в cron с перезапуском NGINX? (y/n): " CRON_SETUP
    if [[ "$CRON_SETUP" == "y" || "$CRON_SETUP" == "Y" ]]; then
        echo "Настраиваем cron для автоматического обновления сертификатов с перезапуском NGINX..."
        (crontab -l 2>/dev/null; echo "0 2 1 */2 * certbot renew --quiet --deploy-hook 'systemctl reload nginx'") | crontab -
    fi
else
    # Добавление cron для обновления сертификатов без NGINX
    read -p "Хотите ли вы добавить обновление сертификатов в cron без перезапуска NGINX? (y/n): " CRON_SETUP
    if [[ "$CRON_SETUP" == "y" || "$CRON_SETUP" == "Y" ]]; then
        echo "Настраиваем cron для автоматического обновления сертификатов без перезапуска NGINX..."
        (crontab -l 2>/dev/null; echo "0 2 1 */2 * certbot renew --force-renewal --quiet") | crontab -
    fi
fi

# Изменение email для уведомлений, только если указан email
if [ -n "$EMAIL" ]; then
    echo "Изменение email для уведомлений на $EMAIL..."
    sudo certbot update_account --email "$EMAIL"
fi

echo "Скрипт завершен. Сертификаты настроены, автоматическое обновление настроено (если выбрано)."
