# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать карту конфигураций?

```
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create configmap domain --from-literal=name=netology.ru
```

#### Результат
(предварительно создан файл nginx.conf с содержимым из [nginx.conf](files/nginx.conf))

```bash
root@vagrant:/home/vagrant# nano nginx.conf
root@vagrant:/home/vagrant# kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created
root@vagrant:/home/vagrant# kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
```

### Как просмотреть список карт конфигураций?

```
kubectl get configmaps
kubectl get configmap
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl get configmaps
NAME               DATA   AGE
domain             1      9s
kube-root-ca.crt   1      69d
nginx-config       1      14s
root@vagrant:/home/vagrant# kubectl get configmap
NAME               DATA   AGE
domain             1      15s
kube-root-ca.crt   1      69d
nginx-config       1      20s
```

### Как просмотреть карту конфигурации?

```
kubectl get configmap nginx-config
kubectl describe configmap domain
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      29s
root@vagrant:/home/vagrant# kubectl describe configmap domain
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
root@vagrant:/home/vagrant# kubectl describe configmap nginx-config
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
server {
    listen 80;
    server_name  netology.ru www.netology.ru;
    access_log  /var/log/nginx/domains/netology.ru-access.log  main;
    error_log   /var/log/nginx/domains/netology.ru-error.log info;
    location / {
        include proxy_params;
        proxy_pass http://10.10.10.10:8080/;
    }
}


BinaryData
====

Events:  <none>
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get configmap nginx-config -o yaml
kubectl get configmap domain -o json
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-05-21T12:13:47Z"
  name: nginx-config
  namespace: default
  resourceVersion: "20411"
  uid: 7ba5babe-684f-4ee9-8e83-459f976b1c21
root@vagrant:/home/vagrant# kubectl get configmap domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-05-21T12:13:52Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "20417",
        "uid": "b5ffc661-fd7c-4ce0-957f-dfb74e9d5dfa"
    }
}
```

### Как выгрузить карту конфигурации и сохранить его в файл?

```
kubectl get configmaps -o json > configmaps.json
kubectl get configmap nginx-config -o yaml > nginx-config.yml
```

#### Результат
(данные обрезаны)

```bash
root@vagrant:/home/vagrant# kubectl get configmaps -o json > configmaps.json
root@vagrant:/home/vagrant# kubectl get configmap nginx-config -o yaml > nginx-config.yml
root@vagrant:/home/vagrant# cat configmaps.json 
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "name": "netology.ru"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2022-05-21T12:13:52Z",
                "name": "domain",
                "namespace": "default",
                "resourceVersion": "20417",
                "uid": "b5ffc661-fd7c-4ce0-957f-dfb74e9d5dfa"
            }
        },
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "-----BEGIN CERTIFICATE-----\nMIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQs\nS6vM/mr10kyCKg==\n-----END CERTIFICATE-----\n"
            },
            "kind": "ConfigMap",
            "metadata": {
                "annotations": {
                    "kubernetes.io/description": "Contains a CA bundle that can be used to verify the kube-apiserver when using internal endpoints such as the internal service IP or kubernetes.default.svc. No other usage is guaranteed across distributions of Kubernetes clusters."
                },
                "creationTimestamp": "2022-03-13T03:11:33Z",
                "name": "kube-root-ca.crt",
                "namespace": "default",
                "resourceVersion": "491",
                "uid": "b760176b-a614-4b64-9a0d-68e03efc8bc2"
            }
        },
        {
            "apiVersion": "v1",
            "data": {
                "nginx.conf": "server {\n    listen 80;\n    server_name  netology.ru www.netology.ru;\n    access_log  /var/log/nginx/domains/netology.ru-access.log  main;\n    error_log   /var/log/nginx/domains/netology.ru-error.log info;\n    location / {\n        include proxy_params;\n        proxy_pass http://10.10.10.10:8080/;\n    }\n}\n"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2022-05-21T12:16:18Z",
                "name": "nginx-config",
                "namespace": "default",
                "resourceVersion": "20539",
                "uid": "dbf35583-56c7-4430-8e6c-5ac04ed0860d"
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
root@vagrant:/home/vagrant# cat nginx-config.yml 
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-05-21T12:16:18Z"
  name: nginx-config
  namespace: default
  resourceVersion: "20539"
  uid: dbf35583-56c7-4430-8e6c-5ac04ed0860d
```

### Как удалить карту конфигурации?

```
kubectl delete configmap nginx-config
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl delete configmap nginx-config
configmap "nginx-config" deleted
root@vagrant:/home/vagrant# kubectl get configmaps
NAME               DATA   AGE
domain             1      96s
kube-root-ca.crt   1      69d
```

### Как загрузить карту конфигурации из файла?

```
kubectl apply -f nginx-config.yml
```

#### Результат

```bash
root@vagrant:/home/vagrant# kubectl apply -f nginx-config.yml
configmap/nginx-config created
root@vagrant:/home/vagrant# kubectl get configmaps
NAME               DATA   AGE
domain             1      4m20s
kube-root-ca.crt   1      69d
nginx-config       1      7s
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
их доступность как в виде переменных окружения, так и в виде примонтированного
тома

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, configmaps) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---
