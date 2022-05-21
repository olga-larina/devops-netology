# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать секрет?

```
openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
```

#### Результат

```bash
root@vagrant:/home/vagrant# mkdir certs
root@vagrant:/home/vagrant# cd ./certs
root@vagrant:/home/vagrant/certs# openssl genrsa -out cert.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
.....++++
................................................++++
e is 65537 (0x010001)
root@vagrant:/home/vagrant/certs# openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
> -subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
root@vagrant:/home/vagrant/certs# cd ..
root@vagrant:/home/vagrant# kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
secret/domain-cert created
```

### Как просмотреть список секретов?

```
kubectl get secrets
kubectl get secret
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-spgbx   kubernetes.io/service-account-token   3      69d
domain-cert           kubernetes.io/tls                     2      74s
root@vagrant:/home/vagrant# kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-spgbx   kubernetes.io/service-account-token   3      69d
domain-cert           kubernetes.io/tls                     2      80s
```

### Как просмотреть секрет?

```
kubectl get secret domain-cert
kubectl describe secret domain-cert
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      98s
root@vagrant:/home/vagrant# kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get secret domain-cert -o yaml
kubectl get secret domain-cert -o json
```

#### Результат
(данные обрезаны)

```bash
root@vagrant:/home/vagrant# kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJRklDQVRFLS0tLS
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLR0VZLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2022-05-21T11:16:28Z"
  name: domain-cert
  namespace: default
  resourceVersion: "17467"
  uid: a947d871-02be-49d2-a9ac-179e17d27c6c
type: kubernetes.io/tls
root@vagrant:/home/vagrant# kubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "LS0tLS1CRUdJTiBDRVJRklDQVRFLS0tLS",
        "tls.key": "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLR0VZLS0tLS0K"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-05-21T11:16:28Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "17467",
        "uid": "a947d871-02be-49d2-a9ac-179e17d27c6c"
    },
    "type": "kubernetes.io/tls"
}
```

### Как выгрузить секрет и сохранить его в файл?

```
kubectl get secrets -o json > secrets.json
kubectl get secret domain-cert -o yaml > domain-cert.yml
```

#### Результат
(данные обрезаны)

```bash
root@vagrant:/home/vagrant# kubectl get secrets -o json > secrets.json
root@vagrant:/home/vagrant# kubectl get secret domain-cert -o yaml > domain-cert.yml
root@vagrant:/home/vagrant# cat secrets.json
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "LS0tLS1CRUdJTiBDRVJU0tCg==",
                "namespace": "ZGVmYXVsdA==",
                "token": "ZXlKaGJHY2lPaUpTVXpJMU5pSXhCNlMyN1VR"
            },
            "kind": "Secret",
            "metadata": {
                "annotations": {
                    "kubernetes.io/service-account.name": "default",
                    "kubernetes.io/service-account.uid": "0725f87c-a104-4c30-875e-560bbdb11bd7"
                },
                "creationTimestamp": "2022-03-13T03:11:33Z",
                "name": "default-token-spgbx",
                "namespace": "default",
                "resourceVersion": "464",
                "uid": "057ec6a7-e1b9-493e-b74e-d2d52be22741"
            },
            "type": "kubernetes.io/service-account-token"
        },
        {
            "apiVersion": "v1",
            "data": {
                "tls.crt": "LS0tLS1CRUdJTiBDRVJRklDQVRFLS0tLS",
                "tls.key": "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLR0VZLS0tLS0K"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-05-21T11:16:28Z",
                "name": "domain-cert",
                "namespace": "default",
                "resourceVersion": "17467",
                "uid": "a947d871-02be-49d2-a9ac-179e17d27c6c"
            },
            "type": "kubernetes.io/tls"
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
root@vagrant:/home/vagrant# cat domain-cert.yml 
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJRklDQVRFLS0tLS
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLR0VZLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2022-05-21T11:16:28Z"
  name: domain-cert
  namespace: default
  resourceVersion: "17467"
  uid: a947d871-02be-49d2-a9ac-179e17d27c6c
type: kubernetes.io/tls
```

### Как удалить секрет?

```
kubectl delete secret domain-cert
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl delete secret domain-cert
secret "domain-cert" deleted
root@vagrant:/home/vagrant# kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-spgbx   kubernetes.io/service-account-token   3      69d
```

### Как загрузить секрет из файла?

```
kubectl apply -f domain-cert.yml
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl apply -f domain-cert.yml
secret/domain-cert created
root@vagrant:/home/vagrant# kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-spgbx   kubernetes.io/service-account-token   3      69d
domain-cert           kubernetes.io/tls                     2      2s
```

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (deployments, pods, secrets) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---
