# Olga Ivanova, devops-10. Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```
    * Какое значение будет присвоено переменной c?
    * Как получить для переменной c значение 12?
    * Как получить для переменной c значение 3?
    
Ответ:  
`c` не будет присвоено значение, т.к. будет ошибка, что нет такой операции сложения `int` и `str`  
Чтобы `c` было присвоено `12`, нужно добавить приведение типов (`a` привести к строке) `c = str(a) + b`  
Чтобы `c` было присвоено `3`, нужно добавить приведение типов (`b` привести к числу) `c = a + int(b)`  

2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, 
   какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, 
   потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. 
   Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```
   
Ответ:  
```python
#!/usr/bin/env python3
import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
proc = os.popen(' && '.join(bash_command))
result_os = proc.read()
proc.close()
cwd = os.getcwd()
#is_change = False
for result in result_os.split('\n'):
   if result.find('modified:') != -1 or result.find('изменено:') != -1:
      prepare_result = result.replace('\tmodified:   ', '').replace('\tизменено:   ', '')
      print(f'{os.path.join(cwd, prepare_result)}')
      #break
```

1 - результат `os.popen()` вынесен в отдельную переменную и выполнен метод `close`  
2 - добавлено получение текущей директории (после `cd`) `cwd = os.getcwd()`  
3 - закомментирована лишняя переменная `is_change = False`  
4 - в поиск и замену результатов `git status` добавлен вариант `изменено` на случай русского `git`  
5 - в вывод `print` в относительный путь файла из `git status` добавлена текущая директория через `os.path.join`  
6 - удалён `break`, из-за которого выполнение прекращалось после того, как было найдено первое вхождение  

3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь 
   к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, 
   которые не являются локальными репозиториями.
   
Ответ:
```python
#!/usr/bin/env python3
import os
import sys

work_dir = ""
if len(sys.argv) >= 2:
   work_dir = sys.argv[1] # 0 параметр - это имя скрипта, 1 параметр (при наличии) - искомый
else:
   work_dir = os.getcwd() # если не задан, то используем текущую директорию

bash_command = [f"cd {work_dir}", "git status 2> >(sed 's/^/CUSTOM_ERROR: /') >&1"] # в вывод ошибки добавляем в начало текст CUSTOM_ERROR:, чтобы удобнее было фильтровать потом, и перенаправляем всё в stdout
proc = os.popen(' && '.join(bash_command))
result_os = proc.read()
proc.close()
cwd = os.getcwd() # запрашиваем ещё раз, т.к. в параметре мог быть относительный путь
#is_change = False
for result in result_os.split('\n'):
   if result.find('modified:') != -1 or result.find('изменено:') != -1:
      prepare_result = result.replace('\tmodified:   ', '').replace('\tизменено:   ', '')
      print(f'{os.path.join(cwd, prepare_result)}')
      #break
   elif result.find("CUSTOM_ERROR:") != -1:
      print(f'Error while reading repo {cwd}')
      break # прерываем, т.к. в выводе может быть несколько строк ошибок
```

4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за 
   DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой, очень часто меняет нам сервера, 
   поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера 
   не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, 
   выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. 
   Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка 
   реализовала сервисы: drive.google.com, mail.google.com, google.com.
   
Ответ:  
```python
#!/usr/bin/env python3
import socket
import time
import datetime

services = {"drive.google.com": "", "mail.google.com": "", "google.com": ""}
max_attempts = 50
cur_attempt = 0
delay = 10

while (cur_attempt < max_attempts):
    for host, prev_ip in services.items():
        try:
            ip = socket.gethostbyname(host)
            now = datetime.datetime.now()
            if (prev_ip != "" and prev_ip != ip):
                print(f'[{now}] [ERROR] {host} IP mismatch: {prev_ip} {ip}')
            else:
                print(f'[{now}] {host} - {ip}')
            services[host] = ip
        except:
            print(f'[{now}] {host} not accessible')
    cur_attempt += 1
    time.sleep(delay)
```

Переменная `max_attempts` введена для ограничения попыток. Если нужно повторять бесконечно, то можно оставить `while (true)`.  

Пример вывода (с дополнительным несуществующим хостом):  
```bash
[2021-07-28 10:27:11.493659] drive.google.com - 142.251.1.194
[2021-07-28 10:27:11.494124] mail.google.com - 64.233.165.18
[2021-07-28 10:27:11.501669] google.com - 64.233.165.138
[2021-07-28 10:27:11.501669] ttt.com not accessible
[2021-07-28 10:27:21.512725] drive.google.com - 142.251.1.194
[2021-07-28 10:27:21.516882] mail.google.com - 64.233.165.18
[2021-07-28 10:27:21.517544] [ERROR] google.com IP mismatch: 64.233.165.138 64.233.165.100
[2021-07-28 10:27:21.517544] ttt.com not accessible
[2021-07-28 10:27:31.528291] drive.google.com - 142.251.1.194
[2021-07-28 10:27:31.528969] [ERROR] mail.google.com IP mismatch: 64.233.165.18 64.233.165.17
[2021-07-28 10:27:31.529652] [ERROR] google.com IP mismatch: 64.233.165.100 64.233.165.113
[2021-07-28 10:27:31.529652] ttt.com not accessible
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации 
в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, 
формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, 
что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным 
репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении 
к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. 
С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, 
как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

Ответ:  
```python
#!/usr/bin/env python3
import os
import sys
import json

if len(sys.argv) < 5:
    raise ValueError("Not enough arguments")

pr_title = sys.argv[1] # заголовок PR
commit_msg = sys.argv[2] # текст коммита
branch_name = sys.argv[3] # имя новой ветки
git_token = sys.argv[4] # токен в git

# создаём ветку, коммитим и пушим изменения
bash_command_push = [f"git checkout -b {branch_name};git add .;git commit -m '{commit_msg}';git push origin {branch_name}"] # предполагается, что мы находимся в папке с репозиторием
proc1 = os.popen(' && '.join(bash_command_push))
proc1.read()
proc1.close()

# узнаём username/project для вызова github API
bash_command_project = ["git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\://' | sed 's/\.git//'"]
proc2 = os.popen(' && '.join(bash_command_project))
project_name = proc2.read().split('\n')[0]
proc2.close()

# создаём PR и получаем его номер
bash_command_pr_create = [f'curl \
  -s -X POST \
  -H "Authorization: token {git_token}" \
  -H "Accept: application/json" \
  https://api.github.com/repos/{project_name}/pulls \
  -d \'{{"head":"{branch_name}","base":"main","title":"{pr_title}"}}\' 2>&1']
proc3 = os.popen(' && '.join(bash_command_pr_create))
pr_str = proc3.read().replace('null', '""')
proc3.close()
pr_number = json.loads(pr_str)['number']

# мерджим PR
bash_command_pr_merge = [f'curl \
  -X PUT \
  -H "Authorization: token {git_token}" \
  https://api.github.com/repos/{project_name}/pulls/{pr_number}/merge \
  -d \'{{"head":"{branch_name}","base":"main","title":"{pr_title}"}}\' 2>&1']
proc4 = os.popen(' && '.join(bash_command_pr_merge))
proc4.read()
proc4.close()
```  

Пример запуска (из локального репозитория): `python3 1.py "My pr" "Commit new feature 1" feature PERSONAL_ACCESS_TOKEN`