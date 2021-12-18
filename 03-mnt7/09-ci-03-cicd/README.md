# Домашнее задание к занятию "09.03 CI\CD"

## Подготовка к выполнению

1. Создаём 2 VM в yandex cloud со следующими параметрами: 2CPU 4RAM Centos7(остальное по минимальным требованиям)
2. Прописываем в [inventory](./infrastructure/inventory/cicd/hosts.yml) [playbook'a](./infrastructure/site.yml) созданные хосты
3. Добавляем в [files](./infrastructure/files/) файл со своим публичным ключом (id_rsa.pub). Если ключ называется иначе - найдите таску в плейбуке, которая использует id_rsa.pub имя и исправьте на своё

### Ответ
Дополнительно в hosts.yml добавлен `ansible_ssh_private_key_file`

4. Запускаем playbook, ожидаем успешного завершения

### Ответ

`[olga@fedora infrastructure]$ ansible-playbook -i inventory/cicd site.yml`

5. Проверяем готовность Sonarqube через [браузер](http://localhost:9000)

### Ответ
[http://51.250.27.119:9000](http://51.250.27.119:9000)

6. Заходим под admin\admin, меняем пароль на свой
7. Проверяем готовность Nexus через [браузер](http://localhost:8081)

### Ответ
[http://51.250.29.178:8081](http://51.250.29.178:8081)

8. Подключаемся под admin\admin123, меняем пароль, сохраняем анонимный доступ

## Знакомство с SonarQube

### Основная часть

1. Создаём новый проект, название произвольное

### Ответ
Manual -> Название `netology` -> Locally -> Run analysis Other (for Python...) OS Linux 

2. Скачиваем пакет sonar-scanner, который нам предлагает скачать сам sonarqube

### Ответ
Делаем через образ docker
```bash
[olga@fedora ~]$ docker pull sonarsource/sonar-scanner-cli
[olga@fedora ~]$ docker run -v /home/olga/docs/projects/devops:/opt/cicd -w /opt/cicd -it sonarsource/sonar-scanner-cli /bin/bash
```

3. Делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
4. Проверяем `sonar-scanner --version`
5. Запускаем анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`

### Ответ
```bash
sonar-scanner \
-Dsonar.projectKey=netology \
-Dsonar.sources=. \
-Dsonar.host.url=http://51.250.27.119:9000 \
-Dsonar.login=593bcc48a73769388d1bee5c05763c50df5fc07f \
-Dsonar.coverage.exclusions=fail.py
```

6. Смотрим результат в интерфейсе
7. Исправляем ошибки, которые он выявил(включая warnings)
8. Запускаем анализатор повторно - проверяем, что QG пройдены успешно
9. Делаем скриншот успешного прохождения анализа, прикладываем к решению ДЗ

### Ответ
![SonarQube](./img/sonar.png)

## Знакомство с Nexus

### Основная часть

1. В репозиторий `maven-public` загружаем артефакт с GAV параметрами:
   1. groupId: netology
   2. artifactId: java
   3. version: 8_282
   4. classifier: distrib
   5. type: tar.gz

### Ответ
Выбираем загрузку в `maven-releases`
Дополнительно - галочка `Generate pom`

2. В него же загружаем такой же артефакт, но с version: 8_102
3. Проверяем, что все файлы загрузились успешно
4. В ответе присылаем файл `maven-metadata.xml` для этого артефакта

### Ответ
![Nexus](./img/nexus.png)  
[maven-metadata.xml](./img/maven-metadata.xml)

### Знакомство с Maven

### Подготовка к выполнению

1. Скачиваем дистрибутив с [maven](https://maven.apache.org/download.cgi)
2. Разархивируем, делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
3. Удаляем из `apache-maven-<version>/conf/settings.xml` упоминание о правиле, отвергающем http соединение( раздел mirrors->id: my-repository-http-unblocker)

### Ответ
Удаляем `maven-default-http-blocker`

5. Проверяем `mvn --version`
6. Забираем директорию [mvn](./mvn) с pom

### Основная часть

1. Меняем в `pom.xml` блок с зависимостями под наш артефакт из первого пункта задания для Nexus (java с версией 8_282)
2. Запускаем команду `mvn package` в директории с `pom.xml`, ожидаем успешного окончания

### Ответ
```bash
[olga@fedora bin]$ bash mvn package -f /home/olga/docs/projects/devops/devops-netology-private/03-mnt7/09-ci-03-cicd/mvn/pom.xml
```

3. Проверяем директорию `~/.m2/repository/`, находим наш артефакт
4. В ответе присылаем исправленный файл `pom.xml`

### Ответ
![maven.png](./img/maven.png)  
[pom.xml](./mvn/pom.xml)

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
