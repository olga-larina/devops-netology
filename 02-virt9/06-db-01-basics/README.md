# Olga Ivanova, devops-10. Домашнее задание к занятию "6.1. Типы и структура СУБД"

## Задача 1

Архитектор ПО решил проконсультироваться у вас, какой тип БД лучше выбрать для хранения определенных данных.

Выберите подходящие типы СУБД для каждой сущности и объясните свой выбор.

### Ответ

Типы сущностей, которые нужно будет хранить в БД:

- Электронные чеки в json виде - документо-ориентированная, где данные хранятся в виде документов, связей между ними и мета-полями. В принципе, можно использовать и реляционную PostgreSQL с её типами данных json и jsonb.
- Склады и автомобильные дороги для логистической компании - графовая, где узлы будут склады, а рёбра - автомобильные дороги. 
- Генеалогические деревья - сетевая, т.к. они позволяют создавать отношения между объектами в форме иерархии, где у одного узла может быть несколько родительских.
- Кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации - ключ-значение с возможностью задать время жизни. Например, Redis, где можно присваивать данным time-to-live.
- Отношения клиент-покупка для интернет-магазина - реляционная СУБД, клиент и покупка - это таблицы, отношение между ними - многие ко многим - реализуется с помощью промежуточной таблицы с внешними ключами.

## Задача 2

Вы создали распределенное высоконагруженное приложение и хотите классифицировать его согласно
CAP-теореме. Какой классификации по CAP-теореме соответствует ваша система
(каждый пункт - это отдельная реализация вашей системы и для каждого пункта надо привести классификацию)?
А согласно PACELC-теореме, как бы вы классифицировали данные реализации?

### Ответ

- Данные записываются на все узлы с задержкой до часа (асинхронная запись):  
AP, т.к. о консистентности на разных узлах в течение часа говорить не можем, но при наличии нескольких узлов будет доступность и устойчивость к разделению.  
PA/EL - и в условиях разделения, и без ставка делается на доступность, запись же происходит асинхронно в течение часа.

- При сетевых сбоях система может разделиться на 2 раздельных кластера:  
AP, т.к. не гарантирует целостность, но выполнены условия по доступности и устойчивости к распаду на секции 
(в случае сетевого разделения узлов системы она продолжает отвечать пользователям на запросы, при этом не гарантируя консистентности данных).  
PA/EC или PA/EL - PA, т.к. в случае разделения ставка делается на доступность, а без сетевого разделения достаточной информации в задании нет - может быть и консистентность, и высокая скорость ответа.  

- Система может не прислать корректный ответ или сбросить соединение:  
CP, т.к. обеспечивает целостный результат и способна функционировать в условиях распада, но в ущерб доступности
(в случае сетевого разделения узлов системы она прекращает отвечать пользователям на запросы, данные остаются консистентными).  
PC/EC - и в условиях разделения, и без ставка делается на консистентность в ущерб доступности.
  
## Задача 3

Могут ли в одной системе сочетаться принципы BASE и ACID? Почему?

### Ответ

Если под одной системой считать одну СУБД, то не могут, т.к. эти принципы противоречат друг другу: ACID обеспечивает 
надёжность, предсказуемость и согласованность СУБД, а по BASE данные могут быть несогласованные.  
А если же под системой считать некую предметную область, то в ней могут использовать СУБД, отвечающие разным принципам. 
Например, ACID - для хранения данных, а BASE - для кэшей.

## Задача 4

Вам дали задачу написать системное решение, основой которого бы послужили:

- фиксация некоторых значений с временем жизни
- реакция на истечение таймаута

Вы слышали о key-value хранилище, которое имеет механизм [Pub/Sub](https://habr.com/ru/post/278237/).
Что это за система? Какие минусы выбора данной системы?

### Ответ

Это Redis - СУБД вида "ключ-значение", данным можно присваивать time-to-live, а также имеется встроенная система pub/sub. 
Минусы:  
1) Все данные хранятся в оперативной памяти. Поэтому необходимо, чтобы у Redis её всегда было достаточно.  
2) Часть данных можно потерять, например (если настраивали периодические дампы), с момента последней синхронизации с диском до отказа сервера.  
3) Есть 2 варианта истечения таймаутов: пассивный (время истечения проверяется только после попытки обращения клиентом) и активный (периодические проверки, которые гарантируют учёт 75% истёкших ключей). 
Это может не подходить по каким-либо причинам (особенно если требуется мгновенная реакция на истечение таймаута).