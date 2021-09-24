# Olga Ivanova, devops-10. Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

### Ответ

Запуск:  
```bash
[olga@fedora ~]$ docker pull postgres:13
[olga@fedora ~]$ docker volume create postgres_data
[olga@fedora ~]$ docker run --name postgres13 -it --rm -p 5432:5432 -e POSTGRES_PASSWORD=password -v postgres_data:/var/lib/postgresql/data -d postgres:13
[olga@fedora ~]$ docker exec -it postgres13 psql -U postgres
postgres=# \?
```

Управляющие команды для:  
- вывода списка БД:  
```text
\l[+]   [PATTERN]      list databases
```
- подключения к БД:  
```text
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                       connect to new database (currently "postgres")
```
- вывода списка таблиц:  
```text
\dt[S+] [PATTERN]      list tables
```
- вывода описания содержимого таблиц:  
```text
\d[S+]  NAME           describe table, view, sequence, or index
```
- выхода из psql:  
```text
\q                     quit psql
```

## Задача 2

Используя `psql`, создайте БД `test_database`.
Изучите [бэкап БД](test_data/test_dump.sql).
Восстановите бэкап БД в `test_database`.
Перейдите в управляющую консоль `psql` внутри контейнера.
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.
**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

### Ответ

Создание БД:  
```text
postgres=# CREATE DATABASE test_database;
```

Восстановление бэкапа:
```text
[olga@fedora test_data]$ docker cp test_dump.sql postgres13:/tmp/test_dump.sql
[olga@fedora test_data]$ docker exec -it postgres13 bash
root@327891f54b02:/# psql -d test_database -U postgres -f /tmp/test_dump.sql
```

Подключение к БД и ANALYZE (выполняем для всей БД с опцией VERBOSE для вывода сообщений о процессе выполнения):
```text
postgres=# \c test_database;
test_database=# ANALYZE VERBOSE;
```

Столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах:  
```text
test_database=# SELECT tablename, attname, avg_width FROM pg_stats WHERE tablename = 'orders';
 tablename | attname | avg_width 
-----------+---------+-----------
 orders    | id      |         4
 orders    | title   |        16
 orders    | price   |         4
(3 rows)
```  
Результат - столбец `title`, соответствующий `avg_width` - 16.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии, предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

### Ответ

Преобразовать обычную таблицу в секционированную и наоборот нельзя. Поэтому создадим новую с секциями и скопируем данные.
В рамках одной транзакции это сделать не получится. Поэтому потребуется, чтобы в течение времени обновления таблица была недоступна для обновлений. 
Это можно достичь, например, переименовав её. Также учитываем, что FROM - это значение >=, а TO - < .
```text
test_database=# CREATE TABLE orders_new (
    id SERIAL NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);
test_database=# CREATE TABLE orders_1 PARTITION OF orders_new
    FOR VALUES FROM (450) TO (MAXVALUE);
test_database=# CREATE TABLE orders_2 PARTITION OF orders_new
    FOR VALUES FROM (MINVALUE) TO (450);
test_database=# ALTER TABLE orders RENAME TO orders_initial;
test_database=# INSERT INTO orders_new (id, title, price) SELECT id, title, price FROM orders_initial;
test_database=# ALTER TABLE orders_new RENAME TO orders;
test_database=# DROP TABLE orders_initial;
test_database=# SELECT * FROM orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  7 | Me and my bash-pet |   499
  8 | Dbiezdmin          |   501
(4 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
(4 rows)
```

Можно было изначально создать секционированную таблицу, а потом при необходимости выполнить `ATTACH PARTITION` или `DETACH PARTITION`
(чтобы в секционированную таблицу добавить / удалить секцию).

В этом задании можно было пойти по-другому и не делать новую секционированную таблицу, а создать таблицы `orders_1` и `orders_2` с обычными условиями 
`CHECK (price > 499)` и `CHECK (price <= 499)` соответственно и унаследовать их `INHERITS (orders)`, а в `orders` сделать правила, в соответствии 
с которыми вставлять данные в нужную таблицу. Но мне кажется, что это не очень удобно.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

### Ответ

Создание дампа:  
```bash
[olga@fedora ~]$ docker exec -it postgres13 bash
root@327891f54b02:/# pg_dump -U postgres -d test_database > /tmp/test_database_dump.sql
```

Т.к. это файл `sql`, можно было бы туда вручную добавить ограничение:  
```text
ALTER TABLE orders ADD CONSTRAINT orders_title_unq UNIQUE (title);
```
Но это сработает только в том случае, если таблица не является секционированной. В случае секционированной будет такая ошибка:  
```text
ERROR:  unique constraint on partitioned table must include all partitioning columns
DETAIL:  UNIQUE constraint on table "orders" lacks column "price" which is part of the partition key.
```