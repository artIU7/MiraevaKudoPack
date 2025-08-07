# Kudo Packing

Система управления складом с клиентскими приложениями для iPad и конфигуратором на ПК и Веб Версией

### Структура проекта

## Backend/ [Серверная часть]
 - app_kudo_zip/		 # Сервер на Vapor (Swift)
 - db_kudo/ 		 # Docker-образ PostgreSQL
##

## Frontend/ [Клиентская часть]
 - KudoPackZip/ 					# Клиент для iPad (Swift)
 - KudoWarehouseConfiguratorZip/ 	# Конфигуратор на Qt C++ (Qt 5.12)
 - KudoAppReactZip/ 				# Веб версия на react.js
 - iBeaconKudoZip/ 				# Эмитация BLE маячка (Swift)
##

## doc/ # Документация API (Текстовый вариант)
🔗 [https://app-kudo.brazil-server.netcraze.pro/api-docs](https://app-kudo.brazil-server.netcraze.pro/api-docs)
##
## csv_data/ # Файлы конфигурации склада
##

### Требования к Серверной части
- Docker 20.10+
- Swift 5.7+ (для разработки)
- PostgreSQL 14+

## 📱 Клиентские приложения

### KudoPack (iPad)
- **Язык**: Swift
- **Требования**: iOS 15+, Xcode 14+

### KudoWarehouseConfigurator (ПК)
- **Язык**: C++/Qt
- **Требования**: Qt 5.12, CMake 3.15+

### KudoAppReact (Web)
- **Язык**: React.js, JavaScript
- **Требования**: node.js,nmp
##
  Клиент развернут в домашней сети с доступом через KeenDNS: 
  #
  Логин: admin
  #
  Пароль: admin
  #
🔗 [https://app-kudo.brazil-server.netcraze.pro/](https://app-kudo.brazil-server.netcraze.pro/)

## Серверная часть

Сервер развернут в домашней сети с доступом через KeenDNS:  
🔗 [https://app-kudo.brazil-server.netcraze.pro/](https://app-kudo.brazil-server.netcraze.pro/)

## Видео прототипа и готовые образы Докера
Собранный докер образ docker.zip
 https://disk.yandex.ru/d/Oy-t-xl_ipES2w
##

### Сборка и запуск приложений локально

1. Загрузить архивы из репозитория:

Запуск клиента (Qt)
Установить QtCreator (Qt 5.12 +)
- Собрать и запустить проект KudoWarehouseConfigurator

Запуск клиента (ipad)
Установить Xcode 10.12 + (swift 5.7 +)
- Собрать и запустить проект KudoPacking

```bash

Запуск клиента (React)
cd frontend/KudoAppReact/
./build_local.sh (скрипт для сборки и запуска приложения)

Запуск сервера
cd /backend/app_kudo/
./build_docker.sh

Запуск сервера с бд и react приложения локально из докер контейнера:
Скачать архив с яндекс диска docker_app.zip

Запуск БД
в терминале ввести команду 
 cd /docker_app/db_docker
 sudo docker-compose up -d
Параметры базы данных в docker-compose.yml используются в настройках запуска сервера:
version: '3.9'

services:
  postgres:
    image: postgres:latest
    container_name: postgres_container
    environment:
      POSTGRES_USER: postgres_user
      POSTGRES_PASSWORD: postgres_password
      POSTGRES_DB: postgres_db
      PGDATA: /var/lib/postgresql/data/pgdata
    ports:
      - "5430:5432"

Запуск сервера и приложения на react
в терминале ввести команду 
cd /docker_app/app_docker
запустить скрипт 
./build_docker.sh
затем необходимо сделать миграцию базы данныхзапустить скрипт 
./migrate_docker.sh

Параметры базы данных в dcoker-compose.yml для приложения
x-shared_environment: &shared_environment
  LOG_LEVEL: ${LOG_LEVEL:-debug}
  DATABASE_HOST: 192.168.2.79
  DATABASE_PORT: 5430
  DATABASE_NAME: postgres_db
  DATABASE_USERNAME: postgres_user
  DATABASE_PASSWORD: postgres_password

DATABASE_HOST локальный IP адресс и параметры базы данных из запущеного контейнера

После запуска контейнера станет доступен сервер с локальным ip и фронтентд !
База будет пустой
При первой миграции создается юзер по дефолту:
 admin
 admin
Для заполнения базы данных , можно воспользоваться csv файлами в репозитории !

<img width="1669" alt="1" src="https://github.com/user-attachments/assets/eba5741b-874a-42ac-8dcf-dd62ca04ad31" />


