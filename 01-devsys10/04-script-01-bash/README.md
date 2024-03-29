# Olga Ivanova, devops-10. Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательные задания

1. Есть скрипт:
   ```bash
   a=1
   b=2
   c=a+b
   d=$a+$b
   e=$(($a+$b))
   ```
   * Какие значения переменным c,d,e будут присвоены?
   * Почему?
   
Ответ:  
Переменной `c` будет присвоено значение `a+b`, т.к. нет знака $ перед названиями, и, соответственно, `a` и `b` не воспринимаются как переменные.  
Переменной `d` будет присвоено значение `1+2`, т.к. переменные `a` и `b` объявлены неявно и по умолчанию считаются строками.  
Переменной `e` будет присвоено значение `3`, т.к. при арифметической замене `$(())` переменные рассматриваются как числа.  
Проверка:  
```bash
[olga@fedora ~]$    a=1
   b=2
   c=a+b
   d=$a+$b
   e=$(($a+$b))
[olga@fedora ~]$ echo $a
1
[olga@fedora ~]$ echo $b
2
[olga@fedora ~]$ echo $c
a+b
[olga@fedora ~]$ echo $d
1+2
[olga@fedora ~]$ echo $e
3
```

2. На нашем локальном сервере упал сервис, и мы написали скрипт, который постоянно проверяет его доступность, 
   записывая дату проверок до тех пор, пока сервис не станет доступным. 
   В скрипте допущена ошибка, из-за которой выполнение не может завершиться, 
   при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
   ```bash
   while ((1==1)
   do
   curl https://localhost:4757
   if (($? != 0))
   then
   date >> curl.log
   fi
   done
   ```
   
Ответ:  
Исправленный вариант:  
```bash
while ((1==1))
do
  curl https://localhost:4757 2>/dev/null 1>/dev/null
  if (($? != 0))
  then
    echo Service is not ok
    date >> curl.log
    sleep 3
  else
    echo Service is ok
    break
  fi
done
```

В условии `((1==1))` пропущена одна правая скобка.  
Чтобы `curl` ничего не выводил, ошибки и вывод перенаправлены в `/dev/null`: `2>/dev/null 1>/dev/null`.  
В условии, когда сервис недоступен, добавлено справочное `echo`, а также `sleep 3`, чтобы не повторять команды без перерыва.  
Добавлено условие `else` с `break`, чтобы цикл завершился, когда сервис станет доступен.  
Если это будет файл, то в начале ещё надо добавить `#!/usr/bin/env bash`.  

3. Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 
   по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.
   
Ответ:
```bash
declare -i a
a=1
ips=("192.168.0.1:80" "173.194.222.113:80" "87.250.250.242:80")
while (($a <= 5))
do
  for ip in ${ips[@]}
  do
    { echo "$a attempt for $ip: "; curl --max-time 2 $ip; } >> test.log 2>&1
  done
  let "a += 1"
  sleep 3
done
```

Создаём переменную `a` (номер попытки) и массив IP. Делаем по 5 попыток для каждого IP с интервалом 3 секунды между попытками.  
В файл пишем и успешный результат выполнения `curl`, и ошибку, а также номер попытки и IP. Таймаут для `curl` - 2 секунды.  

4. Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не 
   окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается

Ответ:
```bash
declare -i available
ips=("192.168.0.1:80" "173.194.222.113:80" "87.250.250.242:80")
available=1
while (($available==1))
do
  for ip in ${ips[@]}
  do
    curl --max-time 2 $ip 2>/dev/null 1>/dev/null
    if (($? != 0))
    then
      echo "$ip is not available" >> error.log
      available=0
      break
    fi
  done
  sleep 3
done
```

Для прерывания цикла вводим переменную `available`, устанавливаем её в 0, когда какой-то IP недоступен.
Можно было бы добавить ещё дополнительную проверку на 0 перед `sleep`, чтобы не ждать дополнительные 3 секунды.

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, 
который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках 
и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

Ответ:  
В папке `.git/hooks` делаем файл `commit-msg` со следующим содержимым:  
```bash
#!/bin/sh
if ! grep -iqE "^\[04-script-01-bash\]" "$1"; then
    echo "Not correct message: should start with [04-script-01-bash]" >&2
    exit 1
else
    cnt=`wc -m "$1" | awk '{print $1}'`
    if (( $cnt > 31 )); then
        echo "Not correct message: should have length <= 30" >&2
        exit 1
    fi
fi
```
Файл: [commit-msg](commit-msg)  
Выводится ошибка и выполнение прерывается, если коммит начинается не с `[04-script-01-bash]` или число символов в файле превышает 31 (с учётом добавления переноса строки в конце).


### Комментарий по ДЗ
Во второй ещё проблема, что место на жёстком диске растёт, для чего нам надо перезаписывать лог (>), а не дополнять его (>>).
В допке необязательно наличие именно фразы “04-script-01-bash”, просто достаточно чего-либо внутри [].