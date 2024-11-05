##### В случае когда у нас уже был выдан сертификат с помощью classic certbot нам будет достаточно просто доустановить Сertbot DNS agent для route 53 (AWS), но перед этим стоит понять какие пакеты использовались (snap или apt)

##### Если certbot был установлен с помощью `apt`, (`yum` для Oracle ) то и  certbot-dns-route53 устанавливаем таким же образом

```bash
sudo apt install python3-certbot-dns-route53
```
---
##### Если же certbot был установлен с помощью `snap` тогда делаем следующие:

##### Устанавливаем символическую ссылку для Certbot

```bash
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

##### Разрешаем Certbot работать должным образом

```bash
sudo snap set certbot trust-plugin-with-root=ok
```
##### Устанавливаем `certbot-dns-route53`

```bash
sudo snap install certbot-dns-route53
```
---
##### Дальше для всех систем и архитектур одинаково
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
sudo ./aws/install
```

##### Проверяем AWS CLI
```bash
aws --version
```


##### Настраиваем AWS CLI
> [!TIP]
> Если мы будем обновлять существующий сертификат, а не добавлять новый, нам не обязательно вставлять данные в `sudo aws configure` 

##### Вводим данные

```
ubuntu@test-SSL$sudo aws configure
AWS Access Key ID [None]: AA2AA2AA2AA2AA2AA2A2
AWS Secret Access Key [None]: P9LXc+y+PLoLyQaxwh7YwdHrjxbxSwpLUxb/fT7c
Default region name [None]: eu-north-1
Default output format [None]:
```

> [!NOTE]
> Ваши данные будут другими, это лишь несуществующий в реальности пример AWS ключей

##### Выдаем сертификат

```bash
sudo certbot certonly \
  --dns-route53 \
  -d example.com
```
