1) Запуск
colima start --kubernetes

2) Билд
docker build -t customer-service:1.0 ./customer-service
docker build -t order-service:1.0 ./order-service

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