### Эта инструкция о том, как поставить и обновлять SSL сертификаты Let's Encryprt даже при закрытом Security Group (AWS)

##### Обновляем пакеты
```bash
sudo apt update
```

##### Устанавливаем NGINX если требуется
```bash
sudo apt install nginx
```

##### Устанавливаем Snap
```bash
sudo apt install snap
```

##### Устанавливаем Certbot
```bash
sudo snap install --classic certbot
```

##### Устанавливаем символическую ссылку для Certbot
```bash
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

##### Разрешаем Certbot работать должным образом
```bash
sudo snap set certbot trust-plugin-with-root=ok
```

##### Устанавливаем Сertbot DNS agent для route 53 (AWS)
```bash
sudo snap install certbot-dns-route53
```

##### Загружаем пакет AWS CLI
```bash
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

##### Устанавливаем unzip
```bash
sudo apt install unzip
```

##### Разархивируем архив
```bash
unzip awscliv2.zip
```

##### Устанавливаем AWS CLI
```bash
sudo  ./aws/install
```

##### Проверяем AWS CLI
```bash
aws --version
```

##### Настраиваем AWS CLI
```bash
sudo  aws configure
```

##### Вводим данные
```
ubuntu@test-SSL$ aws configure
AWS Access Key ID [None]: A2IA2U23AW62KAR2GYAF
AWS Secret Access Key [None]: P9LXc+y+PLoLyQaxwh7YwdHrjxbxSwpLUxb/gT1c
Default region name [None]: eu-north-1
Default output format [None]:
```
> [!IMPORTANT]
> Ваши данные будут другими, это лишь несуществующий в реальности пример AWS ключей

##### Выдаем сертификат
```bash
sudo certbot certonly \
  --dns-route53 \
  -d example.com
```


> [!WARNING]
> Шаг ниже требуется лишь если у вас не настроен NGINX и вам лень это делать вручную
##### Устанавливаем или перевыпускаем сертификаты
```bash
sudo certbot --nginx -d example.com
```

---

### Команды для автоматизации обновления сертификатов

###### Команда принудительного обновления сертификата
```bash
sudo certbot renew --force-renewal --deploy-hook "systemctl reload nginx"
```

##### Команда открытия Crontan
```bash
sudo crontab -e
```

##### Если добавить эту команду в Cron, то сертификат будет принудительно обновляться первого числа каждого второго месяца в 2 часа ночи
```bash
0 2 1 */2 * certbot renew --force-renewal --quiet --deploy-hook "systemctl reload nginx"
```

##### Команда изменение почты для уведомлений выданного сертификата 
```bash
sudo certbot update_account --email new_email@example.com
```

