# Домашнее задание к занятию "09.05 Teamcity"

## Подготовка к выполнению

1. В Ya.Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`
2. Дождитесь запуска teamcity, выполните первоначальную настройку
3. Создайте ещё один инстанс(2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`
4. Авторизуйте агент
5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity)

### Комментарии

В качестве переменной для teamcity-agent указываем внутренний IP машины с temacity-server (`http://10.129.0.5:8111`).  
Установка nexus:
- 2CPU2RAM Centos7 для Nexus
- добавляем хост в hosts.yml 
- добавляет пользователя и путь к ключу ssh
```bash
[olga@fedora .ssh]$ ssh olga@51.250.21.160 -i id_rsa_ya
[olga@fedora devops-netology-private]$ cd ./03-mnt7/09-ci-05-teamcity/infrastructure/
[olga@fedora infrastructure]$ ansible-playbook -i inventory/cicd site.yml
```

Адрес TeamCity - `http://51.250.26.176:8111`  
Адрес Nexus - `http://51.250.21.160:8081`

## Основная часть

1. Создайте новый проект в teamcity на основе fork

### Ответ
fork - `https://github.com/anguisa/example-teamcity`
Выбираем `From repository url` с указанием https ссылки до репозитория.

2. Сделайте autodetect конфигурации
3. Сохраните необходимые шаги, запустите первую сборку master'a
4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean deploy`, иначе `mvn clean test`

### Ответ
Делаем 2 build step с разными goals и условиями (execution conditions - `teamcity.build.branch equals master` или `teamcity.build.branch does-not-equal master`)

5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus

### Ответ
Грузим в Maven settings проекта. Добавляем в User settings шага сборки.

6. В pom.xml необходимо поменять ссылки на репозиторий и nexus

### Ответ
В pom.xml в `distributionManagement` меняем ссылку на nexus

7. Запустите сборку по master, убедитесь что всё прошло успешно, артефакт появился в nexus

### Ответ
Добавляем SSH ключ (приватный), меняем настройки VCS roots на ssh   

8. Мигрируйте `build configuration` в репозиторий

### Ответ
Versioned settings -> Sync enabled -> Store passwords outside of VCS  
В проекте появляется папка .teamcity со всей конфигурацией  
Можно xml, можно kotlin.dsl
НО есть проблема, что оно триггерит сборку при обновлении versioned settings

9. Создайте отдельную ветку `feature/add_reply` в репозитории
10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`
11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике
12. Сделайте push всех изменений в новую ветку в репозиторий

### Ответ
Дополнительно поднимаем версию в pom.xml, иначе будет ошибка в Nexus, т.к. не сможет перезаписать.

13. Убедитесь что сборка самостоятельно запустилась, тесты прошли успешно
14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`
15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки

### Ответ
В настройке самой сборки General Settings -> Artifact paths: `+:target/*.jar`

17. Проведите повторную сборку мастера, убедитесь, что сборка прошла успешно и артефакты собраны
18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity

### Ответ
.teamcity обновляется в master-ветке

19. В ответ предоставьте ссылку на репозиторий

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
