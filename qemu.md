1) Запуск на macOS
```bash
brew install qemu
```
 
2) Настройка socket_vmnet
```bash
brew install socket_vmnet
```
При установке socket_vmnet могут быть предупреждения, 
надо выполнить команды, которые в них предлагаются
Выполняем команду для старта сервиса
```bash
sudo brew services start socket_vmnet
```

Или можно выполнить команду запуска не в режиме демона
```bash
sudo /usr/local/opt/socket_vmnet/bin/socket_vmnet --vmnet-gateway\=192.168.105.1 /usr/local/var/run/socket_vmnet
```

3) Установка Minikube
- для macos
```bash
brew install minikube
``` 
- для остальных можно посмотреть https://kubernetes.io/ru/docs/tasks/tools/install-minikube/

4) Билд образов
```bash
docker build -t customer-service:latest ./customer-service
docker build -t order-service:latest ./order-service
```
Или можно запустить файл build_images.sh
```bash
./build_images.sh
````

5) Стартуем minikube (macOS)
```bash
minikube start --driver qemu --network socket_vmnet --memory='6000M'
```

6) Загрузка локальных образов в Minikube
```bash
minikube image load customer-service:latest
minikube image load order-service:latest
```

6) Проверка ingress
```bash
kubectl get svc -n ingress-nginx
```

7) Установка Ingress если на предыдущем шаге получили пустоту
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

7) Включение ingress в minikube
```bash
minikube addons enable ingress
```

8) Установка helm (если не установлен)
```bash 
brew install helm
```
 
9) Обновление зависимостей для helm чартов (будет установлен PostgreSQL)
```bash
cd my-microservices-app/
helm dependency update .
```

10) Установка Helm-релиза (из папки с чартом)
```bash
cd my-microservices-app/
helm install myapp ./
```

```bash
helm upgrade myapp oci://registry-1.docker.io/bitnamicharts/postgresql \
  --set image.repository=bitnamilegacy/postgresql \
  --set volumePermissions.image.repository=bitnamilegacy/os-shell \
  --set metrics.image.repository=bitnamilegacy/postgres-exporter \
  --set global.security.allowInsecureImages=true
```

10) Проверка установки
```bash
kubectl get pods
``` 
(дождаться пока все поды будут в состоянии Running)
```bash
kubectl get svc
kubectl get ingress
```

Также можно посмотреть логи внутри пода
```bash
kubectl logs -f имя_пода
```

11) Увеличение replicaCount
В файле _values.yaml_ можно увеличить replicaCount у какого-то из сервисов
```bash
cd my-microservices-app/
helm upgrade myapp ./ -f values.yaml
```

Можно также увидеть ревизии выпуска Helm: 
`helm list` - показать текущий релиз в том числе и номер ревизии
`helm diff upgrade` - посмотреть, что изменилось (при наличии плагина 
diff) или просмотрев `helm history myapp`

12) Узнать Ip кластера
```bash
kubectl get nodes -o wide
```

13) Надо прописать в /etc/hosts (macos, linux)
```bash
sudo nano /etc/hosts
```

или для Windows идем в C:\Windows\System32\drivers\etc,
предварительно возможно надо будет включить отображение скрытых файлов,
далее находим файл _hosts_, щелкаем правой кнопкой мыши и выбираем "Запуск от имени администратора"

В файл _hosts_ надо добавить ip, который получили из поля _INTERNAL-IP_ на шаге 12
далее пробел и имя хоста, которое можно найти в файле _values.yaml_ -> 
ищем сервисы customer-service и order-service и в них ищем _hosts_ и далее поле _host_

Далее сохраняем файл _hosts_ 

14) Проверка доменов

http://order.myapp.local/orders

http://order.myapp.local/actuator/health

http://customer.myapp.local/customers

http://customer.myapp.local/actuator/health


### Настройка CI/CD через Jenkins

1) см. файл [README.md](README.md)

2) Убедитесь, что в .env указаны ваши значения из github
Для полей GHCR_TOKEN и GITHUB_TOKEN нужно сгенерить токен в github
Заходите в свой github, далее Settings -> Developer Settings -> Personal access tokens -> Tokens (classic)
Далее либо генерируете новый токен, либо используете существующий 
 
3) Проверка релизов
```bash
kubectl get pods -n test
```
```bash
kubectl get pods -n prod
```

```bash
helm list -n test
```
```bash
helm list -n prod
```
