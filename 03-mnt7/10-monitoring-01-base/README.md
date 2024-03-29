# Домашнее задание к занятию "10.01. Зачем и что нужно мониторить"

## Обязательные задания

1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя 
платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой 
осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы
выведите в мониторинг и почему?

### Ответ
Нужно использовать 4 золотых сигнала мониторинга - время отклика, величина трафика, уровень ошибок, степень загруженности.  
- время обработки http-запроса
- время вычислений для формирования отчётов
- количество http-запросов (трафик)
- количество открытых соединений
- количество неуспешных (4xx/5xx) http-запросов
- количество ошибок при формировании отчётов
- количество ошибок при вычислениях
- количество ошибок при сохранении на диск
- загрузка CPU
- использование RAM
- контроль inodes
- использование файлового хранилища
- IOPS - количество операций ввода/вывода в секунду
- время чтения / записи на диск


2. Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPUla. Также он сказал, 
что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы 
можете ему предложить?

### Ответ
- RAM usage - использование оперативной памяти (как следствие - скорость работы нашего приложения)  
- inodes - для контроля использования файловой системы (если inodes закончатся, то мы не сможем создать новый файл, хотя при этом на диске может остаться свободное место)    
- CPU la (load average) - средняя загрузка процессора (т.е. насколько тяжёлые вычисления в нашем приложении)

Можно предложить заключить SLA (соглашение об уровне обслуживания). Это соглашение с клиентом об измеримых показателях (время безотказной работы, время реагирования и т.п.), 
а также мерах ответственности, если обещания не выполняются (компенсации, продление лицензий и т.п.). Например, там может быть указано, что системы будут доступны 99.9% времени.  
Для этого нужно определить SLO - целевые уровни обслуживания. Например, время безотказной работы - 99.9%. Сюда можно включить такие показатели: % отличных от 4xx/5xx http-кодов, 
% успешно сформированных текстовых отчётов.  
А чтобы понимать фактическое выполнение обязательств, нужно будет рассчитывать SLI (т.е. конкретные величины предоставляемого обслуживания). Например, фактический % 
успешных http-запросов, фактический % успешно сформированных отчётов.


3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою 
очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, 
чтобы разработчики получали ошибки приложения?

### Ответ
Самый простой способ - писать логи в текстовые файлы и давать доступ к ресурсу с ними разработчикам.  
Если есть возможность, то можно рассмотреть вариант с разворачиванием системы сбора логов ELK. Тогда разработчики получат доступ в Kibana.


4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов. 
Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше 
70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?

### Ответ
Ошибка в том, что в числителе нужно учитывать все успешные запросы, а не только с кодами 2xx. Сюда могут также относиться 1xx - информационные, 
3xx - перенаправления. Тогда формула должна иметь вид: (summ_1xx_requests+summ_2xx_requests+summ_3xx_requests)/summ_all_requests или же
(summ_all_requests-summ_4xx_requests-summ_5xx_requests)/summ_all_requests

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Вы устроились на работу в стартап. На данный момент у вас нет возможности развернуть полноценную систему 
мониторинга, и вы решили самостоятельно написать простой python3-скрипт для сбора основных метрик сервера. Вы, как 
опытный системный-администратор, знаете, что системная информация сервера лежит в директории `/proc`. 
Также, вы знаете, что в системе Linux есть  планировщик задач cron, который может запускать задачи по расписанию.

Суммировав все, вы спроектировали приложение, которое:
- является python3 скриптом
- собирает метрики из папки `/proc`
- складывает метрики в файл 'YY-MM-DD-awesome-monitoring.log' в директорию /var/log 
(YY - год, MM - месяц, DD - день)
- каждый сбор метрик складывается в виде json-строки, в виде:
  + timestamp (временная метка, int, unixtimestamp)
  + metric_1 (метрика 1)
  + metric_2 (метрика 2)
  
     ...
     
  + metric_N (метрика N)
  
- сбор метрик происходит каждую 1 минуту по cron-расписанию

Для успешного выполнения задания нужно привести:

а) работающий код python3-скрипта,

б) конфигурацию cron-расписания,

в) пример верно сформированного 'YY-MM-DD-awesome-monitoring.log', имеющий не менее 5 записей,

P.S.: количество собираемых метрик должно быть не менее 4-х.
P.P.S.: по желанию можно себя не ограничивать только сбором метрик из `/proc`.


### Комментарий по ДЗ
Необязательно заключать с клиентом SLA, чтобы мониторить какие-то показатели. Нарушение SLA потенциально ведет к финансовым потерям.
Вместо этого вы сами можете установить SLO и мониторить SLI.

