##### Если у нас используется 2 контейнера (NGINX и CERTBOT) стоит узнать куда сохраняются сертификаты от контейнера certbot. Например:

```bash
cat Project/docker-compose.cert.yml
```

```yml
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
```
##### В данном случае ничего менять не придется и мы установим Certbot

```bash
sudo snap install --classic certbot
```
##### И вернемся к пункту [Classic certbot](https://github.com/neon0ff/SSL/blob/main/Classic%20certbot.md)

---
##### Если же путь не дефолтный для certbot. Например:

```yml
    volumes:
      - ./certbot-etc:/etc/letsencrypt
```

##### Мы можем либо изменить путь до сертификатов в docker-compose для NGINX и снова вернуться к пункту [Classic certbot](https://github.com/neon0ff/SSL/blob/main/Classic%20certbot.md) или же оставить как есть, но выдать сертификат под кастомный путь, предварительно удалив или переименовав папку с сертификатами.

```bash
sudo certbot certonly --standalone --dns-route53 --config-dir /path-to-folder/certbot-etc -d example.com
```
##### В `crontab` в таком случае так же стоит вводить измененный вариант

```
0 0 1 */2 * certbot renew --force --config-dir /path-to-folder/certbot-etc
```
