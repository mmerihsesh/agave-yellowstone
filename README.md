# Agave + Yellowstone Docker

## Подготовка

Склонировать зависимости в `vendor`:

```bash
./scripts/vendor-setup.sh
```

Проверить конфиг:

```bash
cat config/yellowstone.json
```

## Сборка

Собрать Docker-образ:

```bash
DOCKER_BUILDKIT=1 docker build --progress=plain -t agave-yellowstone:latest .
```

## Запуск

Запустить контейнер:

```bash
docker run --rm -it \
  -p 8899:8899 \
  -p 8900:8900 \
  -p 8999:8999 \
  -p 10000:10000 \
  agave-yellowstone:latest
```

## Проверка

После старта должны появиться строки про:
- `JSON RPC URL: http://127.0.0.1:8899`
- `WebSocket PubSub URL: ws://127.0.0.1:8900`

Остановка:

```bash
Ctrl+C
```
