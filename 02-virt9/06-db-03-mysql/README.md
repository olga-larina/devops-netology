# Olga Ivanova, devops-10. Домашнее задание к занятию "6.3. MySQL"

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
Изучите [бэкап БД](test_data/test_dump.sql) и восстановитесь из него.
Перейдите в управляющую консоль `mysql` внутри контейнера.
Используя команду `\h` получите список управляющих команд.
Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
Подключитесь к восстановленной БД и получите список таблиц из этой БД.
**Приведите в ответе** количество записей с `price` > 300.
В следующих заданиях мы будем продолжать работу с данным контейнером.

### Ответ

Запуск:  
```bash
[olga@fedora ~]$ docker pull mysql:8
[olga@fedora ~]$ docker volume create mysql_data
[olga@fedora ~]$ docker run --name mysql8 -it --rm -p 8080:8080 -e MYSQL_ROOT_PASSWORD=password -v mysql_data:/var/lib/mysql -v /home:/tmp/mysql -d mysql:8
```

Создание БД:  
```bash
[olga@fedora ~]$ docker exec -it mysql8 mysql -uroot -ppassword
mysql> CREATE DATABASE test_db;
```

Восстановление из дампа:  
```bash
[olga@fedora ~]$ docker exec -it mysql8 bash
root@7692b616776c:/tmp/mysql/olga# mysql --password -p test_db < /tmp/mysql/olga/test_dump.sql
Enter password: 
```

Управляющие команды и статус БД:
```text
[olga@fedora ~]$ docker exec -it mysql8 mysql -uroot -ppassword
mysql> \h
mysql> \s
--------------
mysql  Ver 8.0.26 for Linux on x86_64 (MySQL Community Server - GPL)

Server version:		8.0.26 MySQL Community Server - GPL
--------------
```

Список таблиц:
```text
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.00 sec)

mysql> use test_db;
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

Количество записей с `price` > 300:  
```text
mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
  - Фамилия "Pretty"
  - Имя "James"
Предоставьте привилегии пользователю `test` на операции SELECT базы `test_db`.
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES, получите данные по пользователю `test` и **приведите в ответе к задаче**.

### Ответ

```text
mysql> CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass'
       WITH 
       MAX_QUERIES_PER_HOUR 100 
       FAILED_LOGIN_ATTEMPTS 3
       PASSWORD EXPIRE INTERVAL 180 DAY
       ACCOUNT UNLOCK
       ATTRIBUTE '{"fname":"James", "lname":"Pretty"}';
mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
mysql> SELECT * FROM information_schema.user_attributes WHERE user = 'test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.
Исследуйте, какой `engine` используется в таблице БД `test_db`, и **приведите в ответе**.
Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`
  
### Ответ

```text
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
mysql> show profiles;
+----------+------------+-------------------+
| Query_ID | Duration   | Query             |
+----------+------------+-------------------+
|        1 | 0.00018200 | SET profiling = 1 |
+----------+------------+-------------------+
1 row in set, 1 warning (0.00 sec)

mysql> SELECT table_name, engine, version FROM information_schema.tables WHERE TABLE_SCHEMA = 'test_db';
+------------+--------+---------+
| TABLE_NAME | ENGINE | VERSION |
+------------+--------+---------+
| orders     | InnoDB |      10 |
+------------+--------+---------+
1 row in set (0.00 sec)

mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.08 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.14 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> show profiles;
+----------+------------+--------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                            |
+----------+------------+--------------------------------------------------------------------------------------------------+
|        1 | 0.00018200 | SET profiling = 1                                                                                |
|        2 | 0.32173275 | SELECT * FROM information_schema.tables                                                          |
|        3 | 0.00212000 | SELECT * FROM information_schema.tables WHERE TABLE_SCHEMA = 'test_db'                           |
|        4 | 0.00188950 | SELECT table_name, engine, version FROM information_schema.tables WHERE TABLE_SCHEMA = 'test_db' |
|        5 | 0.08769050 | ALTER TABLE orders ENGINE = MyISAM                                                               |
|        6 | 0.13964075 | ALTER TABLE orders ENGINE = InnoDB                                                               |
+----------+------------+--------------------------------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```

Продолжительность переключения на MyISAM: 0.8769  
Продолжительность переключения на InnoDB: 0.1396

## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буфера с незакомиченными транзакциями 1 Мб
- Буфер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

### Ответ

```text
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# IO Speed:
# 0 - logs are written and flushed to disk once per second
# 1 - default, for ACID; logs are written and flushed to disk at each transaction commit
# 2 - logs are written after each transaction commit and flushed to disk once per second
innodb_flush_log_at_trx_commit=0

# Compression
innodb_file_per_table=1
innodb_file_format=Barracuda

# Buffer
innodb_log_buffer_size=1048576

# Cache (30% от ОЗУ 16Гб)
innodb_buffer_pool_size=5033164

# Log size
innodb_log_file_size=104857600
```
