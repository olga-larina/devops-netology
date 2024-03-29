# Домашнее задание к занятию "11.02 Микросервисы: принципы"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- Маршрутизация запросов к нужному сервису на основе конфигурации
- Возможность проверки аутентификационной информации в запросах
- Обеспечение терминации HTTPS

Обоснуйте свой выбор.

### Ответ
Сравнительная таблица. [Источник](https://www.moesif.com/blog/technical/api-gateways/How-to-Choose-The-Right-API-Gateway-For-Your-Platform-Comparison-Of-Kong-Tyk-Apigee-And-Alternatives/)

| Продукт                 | Kong                 | Tyk.io  | APIGee                        | AWS Gateway   | Azure Gateway | Express Gateway  |
|-------------------------|----------------------|---------|-------------------------------|---------------|---------------|------------------|
| Сложность развёртывания | 1 нода               | 1 нода  | Много нод с разными ролями    | Облако (PaaS) | Облако (PaaS) | Гибкое           |
| Хранилища данных        | Cassandra / Postgres | Redis   | Cassandra, Zookeper, Postgres | Облако (PaaS) | Облако (PaaS) | Redis            |
| Открытый исходный код   | Да, Apache 2.0       | Да, MPL | Нет                           | Нет           | Нет           | Да, Apache 2.0   |
| Технология              | NGINX/Lua            | GoLang  | Java                          | Закрыто       | Закрыто       | Node.js, Express |
| В облаке                | Нет                  | Нет     | Нет                           | Да            | Да            | Нет              |
| Сообщество              | Крупное              | Среднее | Отсутствует                   | Отсутствует   | Отсутствует   | Небольшое        |
| Авторизация             | Да                   | Да      | Да                            | Да            | Да            | Да               |

Если смотреть информацию по каждому продукту API Gateway, то наиболее предпочтительным кажется Kong. По нему много документации, 
крупное сообщество, проект open source, соответствует всем требованиям, указанным в задании, работает на nginx. 
Либо, если предполагается использовать облачные решения, можно рассмотреть AWS или Azure Gateway.

## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- Поддержка кластеризации для обеспечения надежности
- Хранение сообщений на диске в процессе доставки
- Высокая скорость работы
- Поддержка различных форматов сообщений
- Разделение прав доступа к различным потокам сообщений
- Простота эксплуатации

Обоснуйте свой выбор.

### Ответ
Сравнительная таблица AMQP брокеров. [Источник](https://www.okbsapr.ru/library/publications/shkola_kzi_chadov_mikhalchenko_2019/)

| Критерий \ Брокеры                                                 | RabbitMQ | ActiveMQ   | Qpid C++   | SwiftMQ | Artemis    | Apollo     | Результат сравнения                                                     |
|--------------------------------------------------------------------|----------|------------|------------|---------|------------|------------|-------------------------------------------------------------------------|
| Подписка на сообщения                                              | +        | +          | +          | +       | +          | +          | Равнозначно                                                             |
| Однонаправленная, широковещательная,<br/>групповая передача данных | Все типы | 1 и 2 типы | 1 и 2 типы | 1 тип   | 1 и 2 типы | 1 и 2 типы | RabbitMQ                                                                |
| Упорядоченная доставка сообщений                                   | +        | +          | +          | -       | +          | -          | RabbitMQ, ActiveMQ, Qpid C++ и Artemis                                  |
| Гарантированная доставка сообщений                                 | +        | +          | +          | +       | +          | +          | Artemis и Qpid C++, т.к. гарантируют, что будет доставлено только 1 раз |
| Кластеризация                                                      | +        | +          | +          | +       | +          | -          | Кроме Apollo                                                            |
| Восстановление каналов после потери связи                          | +        | +          | +          | +       | +          | -          | Кроме Apollo                                                            |
| Масштабируемость                                                   | +        | +          | +          | +       | +          | +          | Равнозначно                                                             |
| Контроль доступа                                                   | +        | +          | +          | +       | +          | +          | Равнозначно                                                             |
| SSL/TLS                                                            | +        | +          | +          | +       | +          | +          | Равнозначно                                                             |
| Открытый код                                                       | +        | +          | +          | -       | +          | +          | Кроме SwiftMQ                                                           |

Если выбирать среди AMPQ брокеров, то наиболее предпочтительным выглядит RabbitMQ. Он удовлетворяет требованиям из задания. 
Однако есть ещё брокер Kafka. Если их сравнивать, то Kafka ориентирован на высокую пропускную способность, однако функционал маршрутизации 
несколько ограничен. RabbitMQ ориентирован на доставку сообщений и сложные сценарии маршрутизации. Выбор брокера будет зависеть, в первую очередь, 
от предполагаемой нагрузки.

Сравнительная таблица RabbitMQ и Kafka. [Источник](https://www.bigdataschool.ru/blog/kafka-vs-rabbitmq-big-data.html)

|                    | RabbitMQ / AMQP                             | Kafka                                                                            |
|--------------------|---------------------------------------------|----------------------------------------------------------------------------------|
| Тип                | AMQP (протокол Advanced Messaging Queueing) | Распределённый программный брокер. Микросервисная архитектура. Событийная модель |
| Производительность | 30-40тыс/сек                                | 2 млн/сек                                                                        |
| Payload            | Без ограничений                             | 1 Мб по умолчанию (настраивается)                                                |
| Хранение сообщений | Основано на подтверждении получения         | В зависимости от политики (например, удаляется после 2 дней)                     |
| Маршрутизация      | 4 способа                                   | 1 способ записи на диск                                                          |
| Масштабирование    | Сложнее масштабировать                      | Проще масштабировать                                                             |
| Работа с клиентом  | Обеспечивает логику работы с сообщениями    | Реализация логики на клиентской стороне                                          |

## Задача 3: API Gateway * (необязательная)

### Есть три сервиса:

**minio**
- Хранит загруженные файлы в бакете images
- S3 протокол

**uploader**
- Принимает файл, если он картинка сжимает и загружает его в minio
- POST /v1/upload

**security**
- Регистрация пользователя POST /v1/user
- Получение информации о пользователе GET /v1/user
- Логин пользователя POST /v1/token
- Проверка токена GET /v1/token/validation

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/user

**POST /v1/token**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/token

**GET /v1/user**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис security GET /v1/user

**POST /v1/upload**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис uploader POST /v1/upload

**GET /v1/user/{image}**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис minio  GET /images/{image}

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизаци
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)
[11-microservices-02-principles_add](../11-microservices-02-principles_add)
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
