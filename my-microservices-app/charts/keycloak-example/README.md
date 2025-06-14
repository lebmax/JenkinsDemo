# Keycloak Example Helm Chart

Этот Helm chart разворачивает Keycloak с поддержкой импорта настроек (например, экспортированных реалмов).

## Быстрый старт

1. Поместите ваши файлы экспорта (например, `realm-export.json`) в values.yaml:

```yaml
keycloak:
  import:
    enabled: true
    configs:
      realm-export.json: |
        { ... содержимое вашего json ... }
```

2. Установите чарт:

```sh
helm install my-keycloak ./keycloak-example
```

3. После старта Keycloak будет импортировать ваши настройки из файлов.

## Переменные

- `keycloak.import.configs` — список файлов для импорта (ключ — имя файла, значение — содержимое)
- `keycloak.import.configMountPath` — путь, куда монтируются файлы импорта
- `keycloak.extraEnv` — дополнительные переменные окружения

## Пример values.yaml

```yaml
keycloak:
  import:
    enabled: true
    configs:
      realm-export.json: |
        { ... }
``` 