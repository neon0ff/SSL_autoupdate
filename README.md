# SSL Auto update
### Этапы запуска скрипта
##### Скачать скрипт
```bash
curl -o SSL_autoupdate.sh https://raw.githubusercontent.com/neon0ff/SSL_autoupdate/refs/heads/main/SSL_autoupdate.sh
```
###### Делаем скрипт исполняемым
```bash
sudo chmod +x SSL_autoupdate.sh
```
##### Выполняем скрипт от sudo
```bash
sudo ./SSL_autoupdate.sh
```
##### В моменте может запросить директорию certbot, если она по умолчанию пишем следующиее
```bash
/etc/letsencrypt
```
##### Если же сертификаты выдавали с помощью Docker, то указываем путь до certbot-etc, например:
```bash
/home/ubuntu/project/site/certbot-etc
```
