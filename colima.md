1) Запуск
colima start --cpu 4 --memory 6 --kubernetes --network-address
colima ls

2) Билд
docker build -t customer-service:0.0.1-SNAPSHOT ./customer-service
docker build -t order-service:0.0.1-SNAPSHOT ./order-service

3) Проверка ingress
kubectl get pods -n kube-system

4) Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

5) Проверка ingress
kubectl get svc -n ingress-nginx

или

kubectl get pods -n kube-system | grep ingress

6) Обновление helm чартов
cd my-microservices-app/
helm dependency update .

# Вывод
# Downloading postgresql from repo https://charts.bitnami.com/bitnami
# Already downloaded postgresql from repo https://charts.bitnami.com/bitnami

7) Установка Helm-релиза (из папки с чартом)
helm install myapp ./

8) Проверка установки
kubectl get pods
kubectl get svc
kubectl get ingress

9) Увеличение replicaCount + обновление релиза
helm upgrade myapp ./ -f values.yaml

Совет: Можно также увидеть ревизии выпуска Helm: helm list (должен показать текущий релиз и версию ревизии 
2 после обновления) и подробно посмотреть, что изменилось, командой helm diff upgrade (при наличии плагина 
diff) или просмотрев helm history mymicroservices.

10) Ip кластера

minikube версия "minikube ip"

или

универсальная версия "kubectl get nodes -o wide"

11) /etc/hosts

sudo nano /etc/hosts

12) Проверка доменов

http://order.myapp.local/orders
http://order.myapp.local/actuator/health

http://customer.myapp.local/customers
http://customer.myapp.local/actuator/health

13) Перейти в папку jenkins
cd ../jenkins

14) Запустить jenkins
docker compose up --build

|

sudo docker-compose up --build

15) Проверка jenkins
localhost:8080

16) Проверка релизов
kubectl get pods -n test
kubectl get pods -n prod

helm list -n test
helm list -n prod