# Olga Ivanova, devops-10. Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать немного, поэтому можно использовать любой IDE.
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Также для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/).
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код,
осталось только с ним ознакомиться и поэкспериментировать, как написано в инструкции в левой части экрана.

## Задача 3. Написание кода.
Цель этого задания - закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные
   у пользователя, а можно статически задать в коде.
   Для взаимодействия с пользователем можно использовать функцию `Scanf`:
```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
```

### Ответ
[Решение](file/task1.go)  
```bash
[olga@fedora file]$ go run task1.go
Enter value in meters: 10.23456
Value in feet = 33.577953 
```

1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
```

### Ответ
[Решение](file/task2.go)  
```bash
[olga@fedora file]$ go run task2.go
Min element = 9 
[olga@fedora file]$ go run task2.go
Error = No elements in array 
```

1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код.

### Ответ
[Решение](file/task3.go)  
```bash
[olga@fedora file]$ go run task3.go
3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 72 75 78 81 84 87 90 93 96 99
```

## Задача 4. Протестировать код (необязательно).

Создайте тесты для функций из предыдущего задания.  

[Задание 1](file/task1_test.go)
```bash
[olga@fedora file]$ go test task1.go task1_test.go -v
=== RUN   Test1Task1
--- PASS: Test1Task1 (0.00s)
=== RUN   Test2Task1
--- PASS: Test2Task1 (0.00s)
PASS
ok      command-line-arguments  0.001s
```  

[Задание 2](file/task2_test.go)
```bash
[olga@fedora file]$ go test task2.go task2_test.go -v
=== RUN   Test1Task2
--- PASS: Test1Task2 (0.00s)
=== RUN   Test2Task2
--- PASS: Test2Task2 (0.00s)
PASS
ok      command-line-arguments  0.002s
``` 

Для задания 3 не смогла придумать тест. Только если в функции всё класть в массив, а потом уже распечатывать. 
И тогда в тестах сравнивать содержимое массива.