# Olga Ivanova, devops-10. Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

### Ответ
См. [Dockerfile](file/Dockerfile) и [elasticsearch.yml](file/elasticsearch.yml).  

Сборка и запуск (первый запуск был ошибкой, потребовалось увеличить `vm.max_map_count`):  
```bash
[olga@fedora file]$ docker build -t anguisa/elasticsearch -f Dockerfile .
[olga@fedora file]$ sudo sysctl -w vm.max_map_count=262144
[olga@fedora file]$ docker run -it --rm -p 9200:9200 --name elasticsearch -v /tmp/elasticsearch.yml:/elasticsearch-7.15.0/config/elasticsearch.yml anguisa/elasticsearch
```

Запрос пути с хост машины:  
```bash
[olga@fedora ~]$ curl -X GET "localhost:9200/?pretty"
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "oMPVQ5VbQfilG3AejRehRg",
  "version" : {
    "number" : "7.15.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "79d65f6e357953a5b3cbcc5e2c7c21073d89aa29",
    "build_date" : "2021-09-16T03:05:29.143308416Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Пуш в репозиторий:  
```bash
[olga@fedora ~]$ docker push anguisa/elasticsearch
```
Ссылка: [репозиторий](https://hub.docker.com/repository/docker/anguisa/elasticsearch)

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание.
Получите состояние кластера `elasticsearch`, используя API.
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
Удалите все индексы.

**Важно**

При проектировании кластера `elasticsearch` нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Ответ

Добавление индексов:  
```bash
[olga@fedora ~]$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,"number_of_replicas": 0 } } }'
[olga@fedora ~]$ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 2,"number_of_replicas": 1 } } }'
[olga@fedora ~]$ curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 4,"number_of_replicas": 2 } } }'
```

Список индексов со статусами:  
```bash
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 9xRM6B8kRv-KOPt93HB8tA   1   0         43            0     40.7mb         40.7mb
green  open   ind-1            IjI9VScTQWaf9ilBP2gc5w   1   0          0            0       208b           208b
yellow open   ind-3            6o7Fi45zTJy_lMDxgVTTeg   4   2          0            0       832b           832b
yellow open   ind-2            m51lDNhoR62_eR5OJlSO8Q   2   1          0            0       416b           416b
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Состояние кластера:  
```bash
[olga@fedora ~]$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Удаление индексов:  
```bash
[olga@fedora ~]$ curl -X DELETE 'http://localhost:9200/ind-*?pretty'
{
  "acknowledged" : true
}
```

В данном случае была проблема с ненулевым количеством реплик `number_of_replicas`.  У нас всего одна нода, а реплики должны размещаться на других нодах.  

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API, [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

### Ответ

Создание директории:  
```bash
[olga@fedora ~]$ docker exec -it elasticsearch bash
[elasticsearch@a80af5fe75a7 /]$ mkdir /elasticsearch-7.15.0/shapshots
```

В `elasticsearch.yml` добавляем `path.repo: /elasticsearch-7.15.0/shapshots` и перезапускаем контейнер.  

Регистрация директории как `snapshot repository`:
```bash
[olga@fedora ~]$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'{"type": "fs","settings": {"location": "/elasticsearch-7.15.0/shapshots"}}'
{
  "acknowledged" : true
}
[olga@fedora ~]$ curl -X GET "localhost:9200/_snapshot/netology_backup?pretty"
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/elasticsearch-7.15.0/shapshots"
    }
  }
}
```

Создание индекса `test` с 0 реплик и 1 шардом:  
```bash
[olga@fedora ~]$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,"number_of_replicas": 0 } } }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 9xRM6B8kRv-KOPt93HB8tA   1   0         43            0     40.7mb         40.7mb
green  open   test             L2P1dWzCT6yoXL5HU2rGWA   1   0          0            0       208b           208b
```

Создание снэпшота:  
```bash
[olga@fedora ~]$ curl -X PUT "localhost:9200/_snapshot/netology_backup/netology_snapshot?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "netology_snapshot",
    "uuid" : "ZAfjCbgMT8C4BcaByl7JRg",
    "repository" : "netology_backup",
    "version_id" : 7150099,
    "version" : "7.15.0",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2021-09-26T11:34:34.084Z",
    "start_time_in_millis" : 1632656074084,
    "end_time" : "2021-09-26T11:34:35.285Z",
    "end_time_in_millis" : 1632656075285,
    "duration_in_millis" : 1201,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```

Список файлов в директории со `snapshot`ами:
```bash
[elasticsearch@2e8dcfc3991a shapshots]$ ll /elasticsearch-7.15.0/shapshots
total 40
-rw-r--r--. 1 elasticsearch elasticsearch   835 Sep 26 11:34 index-0
-rw-r--r--. 1 elasticsearch elasticsearch     8 Sep 26 11:34 index.latest
drwxr-xr-x. 1 elasticsearch elasticsearch    88 Sep 26 11:34 indices
-rw-r--r--. 1 elasticsearch elasticsearch 27661 Sep 26 11:34 meta-ZAfjCbgMT8C4BcaByl7JRg.dat
-rw-r--r--. 1 elasticsearch elasticsearch   444 Sep 26 11:34 snap-ZAfjCbgMT8C4BcaByl7JRg.dat
```

Удаление индекса `test` и создание нового индекса `test-2`:  
```bash
[olga@fedora ~]$ curl -X DELETE 'http://localhost:9200/test?pretty'
{
  "acknowledged" : true
}
[olga@fedora ~]$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"index": {"number_of_shards": 1,"number_of_replicas": 0 } } }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 9xRM6B8kRv-KOPt93HB8tA   1   0         43            0     40.7mb         40.7mb
green  open   test-2           6pvdNA8hShaVyYcb_c0z_g   1   0          0            0       208b           208b
```

Восстановление из снэпшота:  
```bash
[olga@fedora ~]$ curl -X POST "localhost:9200/_snapshot/netology_backup/netology_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "accepted" : true
}
[olga@fedora ~]$ curl -X GET 'localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WixBDYSPRUqz4CmnploeSQ   1   0         43            0     40.7mb         40.7mb
green  open   test-2           6pvdNA8hShaVyYcb_c0z_g   1   0          0            0       208b           208b
green  open   test             xwWFaEBtQ_67G-Reg3tgIA   1   0          0            0       208b           208b
```


### Комментарий по ДЗ
https://stackoverflow.com/questions/15694724/shards-and-replicas-in-elasticsearch
