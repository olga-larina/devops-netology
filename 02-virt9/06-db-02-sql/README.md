# Olga Ivanova, devops-10. Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker, поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.
Приведите получившуюся команду или docker-compose манифест.

### Ответ

Используем свою папку для хранения данных PGDATA (по умолчанию - /var/lib/postgresql/data).
```bash
[olga@fedora ~]$ docker pull postgres:12
[olga@fedora ~]$ docker volume create postgres_data
[olga@fedora ~]$ docker volume create postgres_backup
[olga@fedora ~]$ docker run --name postgres12 -it -p 5432:5432 -e POSTGRES_PASSWORD=password -e PGDATA=/var/lib/postgres/data -v postgres_data:/var/lib/postgres/data -v postgres_backup:/var/lib/postgres/backup -d postgres:12
[olga@fedora ~]$ docker exec -it postgres12 psql -U postgres
```

## Задача 2

В БД из задачи 1:
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Ответ

Создание пользователей, БД, таблиц:
```text
postgres=# CREATE USER "test-admin-user";
postgres=# CREATE DATABASE test_db;
postgres=# \c test_db
test_db=# CREATE TABLE orders (
    id    serial,
    name  varchar(255),
    price int,
    CONSTRAINT orders_pk PRIMARY KEY (id)
);
test_db=# CREATE TABLE clients (
    id          serial,
    last_name   varchar(255),
    country     text,
    order_id    bigint,
    CONSTRAINT clients_pk PRIMARY KEY (id),
    CONSTRAINT clients_fk_order_id FOREIGN KEY (order_id) REFERENCES orders (id)
);
test_db=# CREATE INDEX client_country_idx ON clients (country);
test_db=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
test_db=# CREATE USER "test-simple-user";
test_db=# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
```

Список БД:  
```text
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)
```

Описание таблиц:  
```text
test_db=# \d clients
                                     Table "public.clients"
  Column   |          Type          | Collation | Nullable |               Default               
-----------+------------------------+-----------+----------+-------------------------------------
 id        | integer                |           | not null | nextval('clients_id_seq'::regclass)
 last_name | character varying(255) |           |          | 
 country   | text                   |           |          | 
 order_id  | bigint                 |           |          | 
Indexes:
    "clients_pk" PRIMARY KEY, btree (id)
    "client_country_idx" btree (country)
Foreign-key constraints:
    "clients_fk_order_id" FOREIGN KEY (order_id) REFERENCES orders(id)

test_db=# \d orders
                                    Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default               
--------+------------------------+-----------+----------+------------------------------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass)
 name   | character varying(255) |           |          | 
 price  | integer                |           |          | 
Indexes:
    "orders_pk" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_fk_order_id" FOREIGN KEY (order_id) REFERENCES orders(id)
```

SQL-запрос для выдачи всей информации по пользователям с правами над таблицами test_db:  
```text
test_db=# SELECT * FROM information_schema.table_privileges where table_catalog='test_db';
```

Уникальные пользователи с правами над таблицами test_db:
```text
test_db=# SELECT DISTINCT grantee FROM information_schema.table_privileges where table_catalog='test_db';
     grantee      
------------------
 PUBLIC
 postgres
 test-admin-user
 test-simple-user
(4 rows)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы
- приведите в ответе:
    - запросы
    - результаты их выполнения.

### Ответ

Заполнение таблиц данными:  
```text
test_db=# INSERT INTO orders (name, price)
          VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000), ('Гитара', 4000);
test_db=# INSERT INTO clients (last_name, country)
          VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada'), ('Иоганн Себастьян Бах', 'Japan'), 
                 ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');
```

Количество записей для каждой таблицы:  
```text
test_db=# SELECT COUNT(*) FROM orders;
 count 
-------
     5
(1 row)

test_db=# SELECT COUNT(*) FROM clients;
 count 
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys, свяжите записи из таблиц, согласно таблице:

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

Подсказка - используйте директиву `UPDATE`.

### Ответ

Обновление данных:  
```text
test_db=# UPDATE clients c0
          SET order_id = (SELECT o.id
                          FROM orders o
                          WHERE (o.name='Книга' and c1.last_name='Иванов Иван Иванович')
                             OR (o.name='Монитор' and c1.last_name='Петров Петр Петрович')
                             OR (o.name='Гитара' and c1.last_name='Иоганн Себастьян Бах'))
          FROM clients c1
          WHERE c0.id = c1.id;
```

Проверка:  
```text
test_db=# SELECT o.*, c.* FROM clients c FULL JOIN orders o ON c.order_id = o.id;
 id |  name   | price | id |      last_name       | country | order_id 
----+---------+-------+----+----------------------+---------+----------
  3 | Книга   |   500 |  1 | Иванов Иван Иванович | USA     |        3
  4 | Монитор |  7000 |  2 | Петров Петр Петрович | Canada  |        4
  5 | Гитара  |  4000 |  3 | Иоганн Себастьян Бах | Japan   |        5
    |         |       |  4 | Ронни Джеймс Дио     | Russia  |         
    |         |       |  5 | Ritchie Blackmore    | Russia  |         
  2 | Принтер |  3000 |    |                      |         |         
  1 | Шоколад |    10 |    |                      |         |         
(7 rows)
```

Все пользователи, совершившие заказ (3 варианта запроса):  
```text
test_db=# SELECT * FROM clients c WHERE c.order_id IN (SELECT id FROM orders);
test_db=# SELECT * FROM clients c WHERE EXISTS (SELECT 1 FROM orders o WHERE c.order_id = o.id);
test_db=# SELECT * FROM clients c WHERE c.order_id IS NOT NULL;
 id |      last_name       | country | order_id 
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4
(используя директиву EXPLAIN).
Приведите получившийся результат и объясните, что значат полученные значения.

### Ответ

```text
test_db=# EXPLAIN SELECT * FROM clients c WHERE c.order_id IN (SELECT id FROM orders);
                             QUERY PLAN                              
---------------------------------------------------------------------
 Hash Join  (cost=13.15..24.80 rows=130 width=560)
   Hash Cond: (c.order_id = orders.id)
   ->  Seq Scan on clients c  (cost=0.00..11.30 rows=130 width=560)
   ->  Hash  (cost=11.40..11.40 rows=140 width=4)
         ->  Seq Scan on orders  (cost=0.00..11.40 rows=140 width=4)
(5 rows)

test_db=# EXPLAIN SELECT * FROM clients c WHERE EXISTS (SELECT 1 FROM orders o WHERE c.order_id = o.id);
                              QUERY PLAN                               
-----------------------------------------------------------------------
 Hash Join  (cost=13.15..24.80 rows=130 width=560)
   Hash Cond: (c.order_id = o.id)
   ->  Seq Scan on clients c  (cost=0.00..11.30 rows=130 width=560)
   ->  Hash  (cost=11.40..11.40 rows=140 width=4)
         ->  Seq Scan on orders o  (cost=0.00..11.40 rows=140 width=4)
(5 rows)

test_db=# EXPLAIN SELECT * FROM clients c WHERE c.order_id IS NOT NULL;
                          QUERY PLAN                          
--------------------------------------------------------------
 Seq Scan on clients c  (cost=0.00..11.30 rows=129 width=560)
   Filter: (order_id IS NOT NULL)
(2 rows)
```

Видим приблизительную стоимость запроса, ожидаемое число строк, ожидаемый средний размер строк, а также шаги выполнения.  
1 и 2 запросы: используется hash join, т.е. сначала сканируется (Seq Scan) таблица orders, затем она загружается в hash-таблицу, где ключом будут 
те столбцы, которые используются в join (в данном случае orders.id); впоследствии сканируется (Seq Scan) таблица clients и ищутся подходящие записи в 
хэш таблице.  
3 запрос: используется только последовательное сканирование (Seq Scan) таблицы clients с применением фильтра по условию из WHERE.  
3 запрос более оптимален.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
Остановите контейнер с PostgreSQL (но не удаляйте volumes).
Поднимите новый пустой контейнер с PostgreSQL.
Восстановите БД test_db в новом контейнере.
Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

### Ответ

Выгрузка базы в формате custom:  
```text
test_db=# \q
[olga@fedora ~]$ docker exec -it postgres12 bash
root@1d010cf67f80:/# pg_dump -Fc test_db -U postgres >> /var/lib/postgres/backup/backup1.dump
```

Останавливаем контейнер:
```bash
[olga@fedora ~]$ docker stop postgres12
[olga@fedora ~]$ docker rm postgres12
```

Поднимаем новый контейнер, используя только volume для бэкапов:  
```bash
[olga@fedora ~]$ docker run --name postgres12_2 -it -p 5432:5432 -e POSTGRES_PASSWORD=password -v postgres_backup:/var/lib/postgres/backup -d postgres:12
[olga@fedora ~]$ docker exec -it postgres12_2 psql -U postgres
```  

Проверяем, что test_db отсутствует:
```text
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

Восстановление базы:  
```text
[olga@fedora ~]$ docker exec -it postgres12_2 bash
root@918cc0381ad1:/# pg_restore -C -d postgres -U postgres /var/lib/postgres/backup/backup1.dump
```

Проверка:
```text
postgres-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)
```