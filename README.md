# Сервер

Проектный сервер на Node JS. Желательно использовать Node JS v22.18.0 или новее

## Установка

1. Установите зависимости:
```bash
npm install
```
или просто
```bash
npm i
```

2. Создайте файл `.env` в папке server/

3. Настройте переменные окружения в файле `.env`:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=    #Имя БД
DB_USER=postgres
DB_PASSWORD=    #Пароль БД

ENCRYPTION_SALT=6fe1487911    #Случайные значения
JWT_PASSWORD_CODE=efdc97875ae97d75507b415902eabbc5
JWT_PASSWORD_DURATION=24
```

## Запуск

Запустить сервер в режиме разработки с автоматической перезагрузкой при изменении файлов:

```bash
npm run dev
```

Сервер будет доступен по адресу: `http://localhost:5000/api/`


## Структура проекта

```
server/
├── controllers/*                # Контроллеры маршрутов
├── database/
│   ├── database.js              # Подключение к базе данных
│   └── models.js                # Модели данных
├── error/                       # Обработка ошибок
├── middleware/*                 # Все используемые middleware
├── routes/
│   ├── router.js                # Главный роутер
│   └── ...                      # Маршруты
├── .env                         # Переменные окружения
├── index.js                     # Точка входа
├── package.json
└── package-lock.json
```

## Основные скрипты

- `npm run dev` - запуск сервера в режиме разработки
- пока на этом все
