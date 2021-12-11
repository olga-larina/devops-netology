# Olga Ivanova, devops-10. Домашнее задание к занятию "09.01 Жизненный цикл ПО"

Итоговые XML с workflow:  
- [Bug_workflow.xml](./xml/Bug_workflow.xml)
- [Simple_workflow.xml](./xml/Simple_workflow.xml)

## Подготовка к выполнению
1. Получить бесплатную [JIRA](https://www.atlassian.com/ru/software/jira/free)
2. Настроить её для своей "команды разработки"
3. Создать доски kanban и scrum

### Ответ
При создании доски Kanban использовалась расширенная конфигурация.

## Основная часть
В рамках основной части необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить следующий жизненный цикл:
1. Open -> On reproduce
2. On reproduce <-> Open, Done reproduce
3. Done reproduce -> On fix
4. On fix <-> On reproduce, Done fix
5. Done fix -> On test
6. On test <-> On fix, Done
7. Done <-> Closed, Open

Остальные задачи должны проходить по упрощённому workflow:
1. Open -> On develop
2. On develop <-> Open, Done develop
3. Done develop -> On test
4. On test <-> On develop, Done
5. Done <-> Closed, Open

Создать задачу с типом bug, попытаться провести его по всему workflow до Done. Создать задачу с типом epic, к ней привязать несколько задач с типом task, провести их по всему workflow до Done. 
При проведении обеих задач по статусам использовать kanban. Вернуть задачи в статус Open.
Перейти в scrum, запланировать новый спринт, состоящий из задач эпика и одного бага, стартовать спринт, провести задачи до состояния Closed. Закрыть спринт.

Если всё отработало в рамках ожидания - выгрузить схемы workflow для импорта в XML. Файлы с workflow приложить к решению задания.

### Ответ
Workflow создавался в Настройки -> Задачи -> Бизнес-процессы -> Добавить -> `Bug_workflow` и `Simple_workflow`:  
![bug_workflow](img/bug_workflow.png)  
![simple_workflow](img/simple_workflow.png)  

Workflow привязаны к проекту по типам задачи в Настройки -> Задачи -> Схемы бизнес-процесса:  
![workflow_schemes](img/workflow_schemes.png)

Задачи на доске Kanban в Done:  
![kanban](img/kanban.png)

Открытый спринт:  
![sprint](img/sprint1.png)

Завершённый спринт:  
![sprint](img/sprint2.png)

XML выгружены из Настройки -> Задачи -> Бизнес-процессы -> Редактировать -> Экспорт в xml

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
