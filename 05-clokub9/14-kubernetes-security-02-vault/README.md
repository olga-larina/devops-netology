# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Задача 1: Работа с модулем Vault

### Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```
kubectl apply -f 14.2/vault-pod.yml
```

#### Результат
(предварительно создан файл vault-pod.yml с содержимым из [vault-pod.yml](files/vault-pod.yml))

```bash
root@vagrant:/home/vagrant# nano vault-pod.yml
root@vagrant:/home/vagrant# kubectl apply -f vault-pod.yml
pod/14.2-netology-vault created
root@vagrant:/home/vagrant# kubectl get po
NAME                                      READY   STATUS    RESTARTS     AGE
14.2-netology-vault                       1/1     Running   0            52s
```

### Получить значение внутреннего IP пода

```
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
```

Примечание: jq - утилита для работы с JSON в командной строке

#### Результат

```bash
root@vagrant:/home/vagrant# apt install -y jq
root@vagrant:/home/vagrant# kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"172.17.0.8"}]
```

### Запустить второй модуль для использования в качестве клиента

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Установить дополнительные пакеты

```
dnf -y install pip
pip install hvac
```

#### Результат
(fedora почему-то не хотела выполнять `dnf upgrade` в vagrant, поэтому пришлось использовать ubuntu)

```bash
root@vagrant:/home/vagrant# kubectl run -i --tty ubuntu --image=ubuntu --restart=Never -- sh
If you don't see a command prompt, try pressing enter.

# apt update
# apt install python3-pip
# pip install hvac
```

### Запустить интепретатор Python и выполнить следующий код, предварительно поменяв IP и токен

```
import hvac
client = hvac.Client(
    url='http://172.17.0.8:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

#### Результат
(в python3)

```json
{'request_id': '3f7c9de7-0e0b-9a62-3d4b-1fe57b071bf3', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!!'}, 'metadata': {'created_time': '2022-05-21T12:05:37.548368218Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
```

## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, statefulset, service) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---
