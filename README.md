# SSL Сертификат
### Установим 'certbot' на сервер, выполнив команды:
```bash
sudo add-apt-repository ppa:certbot/certbot
```
```bash
sudo apt-get update
```
```bash
sudo apt-get install certbot -y
```
### Получим SSL сертификат для сайта. Выполним следующую команду, указав наше доменное имя вместо example.com:
```bash
sudo certbot certonly --standalone -d example.com
```
### Мы увидим что наш сертификат создан и находиться по этому пути
```bash
Certificate is saved at: /etc/letsencrypt/live/example.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/example.com/privkey.pem
```
### Далее повышенными правами мы их можем скопировать или дать доступ и перемещать как нам удобно

## Примеры настройки конфига на Apache
```bash
<VirtualHost *:80>

        ServerName example.com

        Redirect / https://example.com

</VirtualHost>

<VirtualHost *:443>

        ServerAdmin webmaster@localhost

        DocumentRoot /var/www/html

    ServerName example.com

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile  /etc/letsencrypt/live/example.com/privkey.pem

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```
### После изменения конфига прописать
```bash
sudo a2enmod ssl
```
```bash
sudo systemctl restart apache2
```
```bash
sudo systemctl restart httpd
```
## Примеры настройки конфига на Nginx
```bash
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com;

    ssl_certificate     /etc/ssl/nginx/cert.pem;
    ssl_certificate_key /etc/ssl/nginx/privkey.pem;

    index index.php;
    access_log /dev/fd/1 main;
    error_log /dev/fd/2 notice;

    set $webroot '/usr/share/zabbix';
    root $webroot;

    large_client_header_buffers 8 8k;
    client_max_body_size 10M;

    location = /favicon.ico { log_not_found off; }
    location = /robots.txt { allow all; log_not_found off; access_log off; }

    # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
    location ~ /\. { deny all; access_log off; log_not_found off; }

    # caching of files
    location ~* \.ico$ { expires 1y; }
    location ~* \.(js|css|png|jpg|jpeg|gif|xml|txt)$ { expires 14d; }

    location ~ /(app\/|conf[^\.]|include\/|local\/|locale\/|vendor\/) {
        deny all;
        return 404;
    }

    location ~ ^/(status|ping)$ {
        access_log off;
        fastcgi_pass unix:/tmp/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $webroot$fastcgi_script_name;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ .php$ {
        fastcgi_pass unix:/tmp/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $webroot$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_param REQUEST_METHOD $request_method;
        fastcgi_param CONTENT_TYPE $content_type;
        fastcgi_param CONTENT_LENGTH $content_length;
        fastcgi_intercept_errors on;
        fastcgi_ignore_client_abort off;
        fastcgi_connect_timeout 60;
        fastcgi_send_timeout 180;
        fastcgi_read_timeout 501;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```
