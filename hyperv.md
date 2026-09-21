# Запуск проекта в Minikube на Windows через Hyper-V

Команды ниже выполняются в PowerShell из корня проекта `JenkinsDemo`.

## 1. Проверка Hyper-V

Откройте PowerShell от имени администратора и проверьте состояние Hyper-V:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

Если Hyper-V отключён, включите его и перезагрузите Windows:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart
Restart-Computer
```

После перезагрузки снова откройте PowerShell от имени администратора.

## 2. Выбор виртуального коммутатора Hyper-V

Посмотрите список доступных виртуальных коммутаторов:

```powershell
Get-VMSwitch
```

Обычно подходит встроенный коммутатор `Default Switch`:

```powershell
$SwitchName = "Default Switch"
Get-VMSwitch -Name $SwitchName
```

Если `Default Switch` отсутствует, посмотрите имена активных сетевых адаптеров:

```powershell
Get-NetAdapter | Where-Object Status -eq "Up"
```

Затем создайте внешний коммутатор, указав имя нужного сетевого адаптера:

```powershell
New-VMSwitch -Name "MinikubeExternal" -NetAdapterName "ИМЯ_СЕТЕВОГО_АДАПТЕРА" -AllowManagementOS $true
$SwitchName = "MinikubeExternal"
```

## 3. Проверка установленных инструментов

`kubectl` и Minikube уже должны быть установлены. Docker нужен для сборки локальных образов:

```powershell
kubectl version --client
minikube version
docker version
```

## 4. Сборка образов

```powershell
docker build -t customer-service:latest .\customer-service
docker build -t order-service:latest .\order-service
```

## 5. Запуск Minikube через Hyper-V

```powershell
minikube start --driver=hyperv --hyperv-virtual-switch="$SwitchName" --memory=6000m
```

Проверьте состояние кластера:

```powershell
minikube status
kubectl cluster-info
```

## 6. Загрузка локальных образов в Minikube

```powershell
minikube image load customer-service:latest
minikube image load order-service:latest
```

Проверьте, что образы появились внутри Minikube:

```powershell
minikube image ls | Select-String "customer-service|order-service"
```

## 7. Включение Ingress

```powershell
minikube addons enable ingress
```

Дождитесь готовности Ingress-контроллера:

```powershell
kubectl wait --namespace ingress-nginx --for=condition=Ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
kubectl get pods,svc --namespace ingress-nginx
```

## 8. Установка Helm

Проверьте, установлен ли Helm:

```powershell
helm version
```

Если команда не найдена, установите Helm через WinGet:

```powershell
winget install --exact --id Helm.Helm --accept-source-agreements --accept-package-agreements
```

Либо по инструкции https://helm.sh/docs/intro/install/

После установки откройте новое окно PowerShell и снова перейдите в корень проекта `JenkinsDemo`.

## 9. Обновление зависимостей Helm-чарта

Команда загрузит зависимости, включая PostgreSQL:

```powershell
helm dependency update .\my-microservices-app
```

## 10. Установка Helm-релиза

```powershell
helm install myapp .\my-microservices-app
```

## 11. Проверка установки

```powershell
kubectl get pods
kubectl get svc
kubectl get ingress
```

Дождитесь, пока все поды перейдут в состояние `Running` и будут готовы:

```powershell
kubectl get pods --watch
```

Для выхода из режима наблюдения нажмите `Ctrl+C`.

Чтобы посмотреть логи конкретного пода:

```powershell
$PodName = "ИМЯ_ПОДА"
kubectl logs -f $PodName
```

## 12. Изменение количества реплик

Откройте `values.yaml` и измените `replicaCount` у нужного сервиса:

```powershell
notepad.exe .\my-microservices-app\values.yaml
```

Примените изменения:

```powershell
helm upgrade myapp .\my-microservices-app -f .\my-microservices-app\values.yaml
```

Посмотрите текущий релиз и историю его ревизий:

```powershell
helm list
helm history myapp
```

## 13. Получение IP-адреса Minikube

```powershell
$MinikubeIp = (minikube ip).Trim()
$MinikubeIp
kubectl get nodes -o wide
```

## 14. Настройка файла hosts

Откройте файл `hosts` от имени администратора:

```powershell
Start-Process notepad.exe -Verb RunAs -ArgumentList "$env:SystemRoot\System32\drivers\etc\hosts"
```

Добавьте в конец файла две строки, заменив `MINIKUBE_IP` значением переменной `$MinikubeIp` из предыдущего шага:

```text
MINIKUBE_IP customer.myapp.local
MINIKUBE_IP order.myapp.local
```

Например:

```text
192.168.137.10 customer.myapp.local
192.168.137.10 order.myapp.local
```

Сохраните файл и очистите DNS-кеш Windows:

```powershell
Clear-DnsClientCache
```

## 15. Проверка доменов

```powershell
curl.exe http://order.myapp.local/orders
curl.exe http://order.myapp.local/actuator/health
curl.exe http://customer.myapp.local/customers
curl.exe http://customer.myapp.local/actuator/health
```

## Настройка CI/CD через Jenkins

См. файл [README.md](README.md).

## Удаление и очистка

```powershell
minikube delete --all --purge
```
