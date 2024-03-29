# Olga Ivanova, devops-10. Домашнее задание к занятию "08.05 Тестирование Roles"

## Итоговый алгоритм

- Локально установлено:
```bash
pip3 install "molecule==3.4.0"
pip3 install "molecule-docker"
````
- Для сборки образа:
  Выполнена регистрация на `https://developers.redhat.com/`

```bash
[olga@fedora 08-ansible-05-testing]$ docker login https://registry.redhat.io
Username: olga.a.ivanova
Password: 
[olga@fedora 08-ansible-05-testing]$ docker build -t img_for_ansible .
```

- Elastic взят из mnt-homeworks-ansible, tag 2.0.3 https://github.com/netology-code/mnt-homeworks-ansible/tree/2.0.3. 
Дополнительно внесены правки в handlers (`and ansible_virtualization_type != 'podman'`).
Использовался локальный git-репозиторий (через переменную `ANSIBLE_ROLES_PATH: /opt/ansible-testing` в molecule.yml -> provisioner -> env).
Поэтому файл `requirements.yml` не нужен + `dependency` в molecule.yml закомментирован.

- Всё выполнялось внутри контейнера.
```bash
[olga@fedora devops]$ docker run --privileged=True -v /home/olga/docs/projects/devops:/opt/ansible-testing -w /opt/ansible-testing -it img_for_ansible /bin/bash
```
Внутри контейнера:
```bash
pip3 install -r ./devops-netology-private/03-mnt7/08-ansible-05-testing/test-requirements.txt --force
yum install git -y
```

- Создание сценария: `molecule init scenario --driver-name docker`

- Запуски выполнялись `molecule --debug -vvv test --destroy=never`. Перед последующим лучше `molecule destroy`, т.к. из-за
этого иногда падало. Внутрь заходила `molecule login --host centos7`

- Centos8 требовал rpm, а не yum, поэтому использован Centos7.

- Посмотреть матрицу конкретного сценария: `molecule matrix test -s tox`

- Запустить конкретный сценарий: `molecule test -s tox`

- Verify в kibana отрабатывает не с 1-го раза, видимо, не успевает запуститься (мы ведь не ждём, а запускаем в бэкграунде)

- Логи kibana не нашла

Остальное см. в [kibana-role](https://github.com/anguisa/kibana-role) и [filebeat-role](https://github.com/anguisa/filebeat-role).

## Подготовка к выполнению
1. Установите molecule: `pip3 install "molecule==3.4.0"`
2. Соберите локальный образ на основе [Dockerfile](./Dockerfile)

## Основная часть

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для kibana, logstash. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите `molecule test` внутри корневой директории elasticsearch-role, посмотрите на вывод команды.
2. Перейдите в каталог с ролью kibana-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert'ов в verify.yml файл, для проверки работоспособности kibana-role (проверка, что web отвечает, проверка логов, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Повторите шаги 2-4 для filebeat-role.
6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Tox

1. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/elasticsearch-role -w /opt/elasticsearch-role -it <image_name> /bin/bash`, где path_to_repo - путь до корня репозитория с elasticsearch-role на вашей файловой системе.
2. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
3. Добавьте файл `tox.ini` в корень репозитория каждой своей роли.
4. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.
5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
6. Запустите `docker` контейнер так, чтобы внутри оказались обе ваши роли.
7. Зайдите поочерёдно в каждую из них и запустите команду `tox`. Убедитесь, что всё отработало успешно.
8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в каждом репозитории. Ссылки на репозитории являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечате адекватно.
4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
5. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
6. Выложите свои roles в репозитории. В ответ приведите ссылки.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
