#!/bin/bash

# Функция для установки цветов
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Файл с путем до сертификатов
CERT_PATH_FILE="path-to-certs"

# Проверка на запуск с правами root или sudo
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Скрипт должен быть запущен с правами sudo!${NC}"
        exit 1
    fi
}

# Функция для чтения пути из файла
read_cert_path() {
    if [[ -f "$CERT_PATH_FILE" ]]; then
        CERT_PATH=$(<"$CERT_PATH_FILE")

        if [[ -z "$CERT_PATH" ]]; then
            echo -e "${YELLOW}Файл '$CERT_PATH_FILE' пуст. Введите путь до директории хранения сертификатов.${NC}"
            get_cert_path
        else
            echo -e "${GREEN}Путь до сертификатов: $CERT_PATH${NC}"
            check_directory
        fi
    else
        echo -e "${YELLOW}Файл '$CERT_PATH_FILE' не найден. Введите путь до директории хранения сертификатов.${NC}"
        get_cert_path
    fi
}

# Функция для запроса пути у пользователя
get_cert_path() {
    read -p "Введите путь до директории хранения сертификатов: " CERT_PATH

    if [[ -n "$CERT_PATH" ]]; then
        echo "$CERT_PATH" > "$CERT_PATH_FILE"
        echo -e "${GREEN}Путь сохранен в '$CERT_PATH_FILE'.${NC}"
        check_directory
    else
        echo -e "${RED}Путь не может быть пустым. Попробуйте снова.${NC}"
        get_cert_path
    fi
}

# Функция для проверки существования директории
check_directory() {
    if [[ -d "$CERT_PATH" ]]; then
        echo -e "${GREEN}Директория сертификатов существует.${NC}"
        get_domain
    else
        echo -e "${RED}Директория сертификатов не найдена. Проверьте путь.${NC}"
        get_cert_path
    fi
}

# Функция для получения домена из папки сертификатов
get_domain() {
    LIVE_DIR="$CERT_PATH/live"

    if [[ -d "$LIVE_DIR" ]]; then
        DOMAIN=$(find "$LIVE_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1 | xargs -I {} basename {})

        if [[ -n "$DOMAIN" ]]; then
            echo -e "${GREEN}Обнаружен домен: $DOMAIN${NC}"
            update_certificates
        else
            echo -e "${RED}Не найдено доменное имя в '$LIVE_DIR'. Проверьте структуру директорий.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Директория 'live/' не найдена в '$CERT_PATH'.${NC}"
        exit 1
    fi
}

# Функция для обновления сертификатов через Docker
update_certificates() {
    echo -e "${GREEN}Запуск обновления сертификатов для $DOMAIN...${NC}"

    docker run --rm \
        -v "$CERT_PATH:/etc/letsencrypt" \
        certbot/dns-route53 certonly \
        --force-renewal --dns-route53 --non-interactive --agree-tos \
        -d "$DOMAIN"

    echo -e "${GREEN}Обновление завершено.${NC}"

    reload_nginx
}

# Функция для нахождения контейнера с Nginx и отправки сигнала reload
reload_nginx() {
    echo -e "${GREEN}Ищем контейнер Nginx...${NC}"

    NGINX_CONTAINER_ID=$(docker ps --filter "name=nginx" --format "{{.ID}}")

    if [[ -n "$NGINX_CONTAINER_ID" ]]; then
        echo -e "${GREEN}Найден контейнер Nginx: $NGINX_CONTAINER_ID. Выполняем reload...${NC}"
        docker exec "$NGINX_CONTAINER_ID" nginx -s reload
        echo -e "${GREEN}Nginx в Docker успешно перезапущен.${NC}"
    else
        echo -e "${YELLOW}Контейнер Nginx не найден. Проверяем локальный Nginx...${NC}"
        if command -v nginx &> /dev/null; then
            echo -e "${GREEN}Локальный Nginx найден. Выполняем reload...${NC}"
            sudo nginx -s reload
            echo -e "${GREEN}Локальный Nginx успешно перезапущен.${NC}"
        else
            echo -e "${RED}Nginx не найден ни в Docker, ни в системе. Проверьте его установку.${NC}"
        fi
    fi
}

# Функция для добавления скрипта в cron
add_to_cron() {
    # Получаем абсолютный путь к текущему скрипту
    SCRIPT_PATH=$(realpath "$0")

    # Проверка, существует ли уже задание в cron
    CRON_JOB="0 0 1,16 * * $SCRIPT_PATH"

    if ! crontab -l | grep -F "$CRON_JOB" > /dev/null; then
        echo -e "${GREEN}Добавляем задание в cron...${NC}"
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo -e "${GREEN}Задание успешно добавлено в cron. Скрипт будет выполняться 1-го и 16-го числа каждого месяца.${NC}"
    else
        echo -e "${YELLOW}Задание уже существует в cron.${NC}"
    fi
}

# Запрос на добавление в cron
add_to_cron_prompt() {
    # Проверка наличия задания в cron перед тем, как запрашивать добавление
    SCRIPT_PATH=$(realpath "$0")
    CRON_JOB="0 0 1,16 * * $SCRIPT_PATH"

    if crontab -l | grep -F "$CRON_JOB" > /dev/null; then
        echo -e "${YELLOW}Задание уже существует в cron, пропускаем добавление.${NC}"
    else
        read -p "Хотите добавить этот скрипт в cron для выполнения 1-го и 16-го числа каждого месяца? (y/n): " add_to_cron
        if [[ "$add_to_cron" == "y" || "$add_to_cron" == "Y" ]]; then
            add_to_cron
        else
            echo -e "${GREEN}Скрипт не будет добавлен в cron.${NC}"
        fi
    fi
}

# Проверка на запуск с правами sudo
check_sudo

# Запуск
read_cert_path
add_to_cron_prompt
