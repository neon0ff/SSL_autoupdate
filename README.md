###   Обновление сертификатов с помощью certbot-dns-route53 
##### Для начала надо определить способ ранее полученных сертификатов.

- C[lassic certbot]([url](https://github.com/neon0ff/SSL/blob/main/Classic%20certbot.md))
- [Certbot docker-compose]([url](https://github.com/neon0ff/SSL/blob/main/Certbot%20docker-compose.md))

### Команды для автоматизации обновления сертификатов

##### Команда принудительного обновления сертификата c перезапуском NGINX после успешного обновления ключей

```bash
sudo certbot renew --force-renewal --deploy-hook "systemctl reload nginx"
```

> [!TIP]
>Если вместо обычного NGINX используется Docker то можно сделать перезапуск определенного контейнера или другого сервиса, например: Apache2

##### Команда открытия Crontan

```bash
sudo crontab -e
```

##### Для Oracle

```bash
sudo EDITOR=nano crontab -e
```

##### Если добавить эту команду в Cron, то сертификат будет принудительно обновляться первого числа каждого второго месяца в 2 часа ночи

```bash
0 2 1 */2 * certbot renew --force-renewal --quiet --deploy-hook "systemctl reload nginx"
```

##### Команда изменение почты для уведомлений выданного сертификата 

```bash
sudo certbot update_account --email new_email@example.com
```
