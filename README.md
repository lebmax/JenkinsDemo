# YandexHelmApp: Jenkins + Docker + Kubernetes + Helm

## Что делает проект

Проект автоматизирует CI/CD процесс для двух микросервисов — `customer-service` и `order-service`. Он выполняет:

- сборку и тестирование кода;
- сборку Docker-образов;
- публикацию образов в GitHub Container Registry (GHCR);
- деплой в кластер Kubernetes с помощью Helm.

Все этапы выполняются через Jenkins Pipeline.

## Состав проекта

- Jenkins (в Docker-контейнере)
- Kubernetes (включён в Docker Desktop)
- Helm и kubectl (предустановлены в контейнере Jenkins)
- Docker Registry: GHCR
- Helm-чарты для каждого сервиса
- CI/CD pipeline (`Jenkinsfile`)

---

## Подготовка

### 1.  см. файл [qemu.md](qemu.md)
 
### 2. Создайте файл `jenkins_kubeconfig.yaml`

Jenkins будет использовать этот файл для доступа к Kubernetes.

Выполните в терминале:

```bash
cp ~/.kube/config jenkins_kubeconfig.yaml
```

### 3. Создайте `.env` файл

Создайте файл `.env` в корне проекта:

```env
# Путь до локального kubeconfig-файла
KUBECONFIG_PATH=/Users/username/.kube/jenkins_kubeconfig.yaml

# Параметры для GHCR
GITHUB_USERNAME=your-username
GITHUB_TOKEN=ghp_...
GHCR_TOKEN=ghp_...

# Docker registry (в данном случае GHCR)
DOCKER_REGISTRY=ghcr.io/your-username
GITHUB_REPOSITORY=your-username/YandexHelmApp

# Пароль к базе данных PostgreSQL
DB_PASSWORD=your-db-password
```

> Убедитесь, что ваш GitHub Token имеет права `write:packages`, `read:packages` и `repo`.

---

### 4. Запустите Jenkins

```bash
cd jenkins
docker compose up -d --build
```

Jenkins будет доступен по адресу: [http://localhost:8080](http://localhost:8080)

---

## Как использовать

1. Откройте Jenkins: [http://localhost:8080](http://localhost:8080)
2. Перейдите в задачу `YandexHelmApp` → `Build Now`
3. Jenkins выполнит:
   - сборку и тесты
   - сборку Docker-образов
   - публикацию образов в GHCR
   - деплой в Kubernetes в два namespace: `test` и `prod`

---

## Проверка успешного деплоя

### 1. Добавьте записи в `/etc/hosts`

```bash
sudo nano /etc/hosts
```

Добавьте:

```text
127.0.0.1 customer.test.local
127.0.0.1 order.test.local
127.0.0.1 customer.prod.local
127.0.0.1 order.prod.local
```

### 2. Отправьте запросы на `/actuator/health`

```bash
curl -s http://customer.test.local/actuator/health
curl -s http://order.test.local/actuator/health
curl -s http://customer.prod.local/actuator/health
curl -s http://order.prod.local/actuator/health
```

**Ожидаемый ответ:**

```json
{"status":"UP","groups":["liveness","readiness"]}
```

---

## Завершение работы и очистка

Если вы хотите полностью остановить Jenkins, удалить namespace'ы `test` и `prod`, а также все установленные ресурсы, используйте скрипт `nuke-all.sh`.

Он находится в папке `jenkins`:

```bash
cd jenkins
./nuke-all.sh
```