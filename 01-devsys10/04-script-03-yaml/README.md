# Olga Ivanova, devops-10. Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
{ "info" : "Sample JSON output from our service\t",
   "elements" :[
       { "name" : "first",
       "type" : "server",
       "ip" : 7175 
       },
       { "name" : "second",
       "type" : "proxy",
       "ip : 71.78.22.43
       }
   ]
}
```
Нужно найти и исправить все ошибки, которые допускает наш сервис

Ответ:  
Исправлено форматирование.
У второго `ip` добавлены закрывающие кавычки.  
Добавлены кавычки у значения `ip`.  
Итоговый вариант:  
```json
{
   "info": "Sample JSON output from our service\t",
   "elements": [
      {
         "name": "first",
         "type": "server",
         "ip": 7175
      },
      {
         "name": "second",
         "type": "proxy",
         "ip": "71.78.22.43"
      }
   ]
}
```
Также можно все значения `ip` обернуть в кавычки, чтобы структура объектов (по ключам и типу данных) в массиве `elements` соответствовала друг другу.

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. 
   К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису:
   { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

Ответ:  
```python
#!/usr/bin/env python3
import socket
import time
import datetime
import yaml # добавлено 04-script-03-yaml
import json # добавлено 04-script-03-yaml

services = {"drive.google.com": "", "mail.google.com": "", "google.com": ""}
max_attempts = 50
cur_attempt = 0
delay = 10
changed = False # добавлено 04-script-03-yaml

while (cur_attempt < max_attempts):
    for host, prev_ip in services.items():
        try:
            ip = socket.gethostbyname(host)
            now = datetime.datetime.now()
            if (prev_ip != "" and prev_ip != ip):
                print(f'[{now}] [ERROR] {host} IP mismatch: {prev_ip} {ip}')
                changed = True # добавлено 04-script-03-yaml
            else:
                print(f'[{now}] {host} - {ip}')
            services[host] = ip
        except:
            print(f'[{now}] {host} not accessible')
    # добавлено 04-script-03-yaml
    if (changed or cur_attempt == 0):
       arr = []
       for host, ip in services.items():
          arr.append({host:ip})
       to_write = {'services': arr}
       with open('services.yml', 'w') as ym:
          ym.write(yaml.dump(to_write, indent=2, explicit_start=True, explicit_end=True))
       with open('services.json', 'w') as js:
          js.write(json.dumps(to_write, indent=2))
    #
    cur_attempt += 1
    changed = False # добавлено 04-script-03-yaml
    time.sleep(delay)
```

Обновляем файлы в том случае, если первая попытка или же было изменение IP.  
Перед записью преобразуем dict в list и кладём его в новый dict в качестве значения, чтобы была необходимая структура.  
Пример итоговых файлов:  
`services.yml`:  
```yaml
---
services:
   - drive.google.com: 173.194.221.194
   - mail.google.com: 64.233.165.17
   - google.com: 64.233.165.113
...
```
`services.json`:
```json
{
   "services": [
      {
         "drive.google.com": "173.194.221.194"
      },
      {
         "mail.google.com": "64.233.165.17"
      },
      {
         "google.com": "64.233.165.113"
      }
   ]
}
```