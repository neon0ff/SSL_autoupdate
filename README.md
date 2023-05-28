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
