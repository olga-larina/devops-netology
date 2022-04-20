# Домашнее задание к занятию "13.5 поддержка нескольких окружений на примере Qbec"
Приложение обычно существует в нескольких окружениях. Для удобства работы следует использовать соответствующие инструменты, например, Qbec.

## Задание 1: подготовить приложение для работы через qbec
Приложение следует упаковать в qbec. Окружения должно быть 2: stage и production. 

Требования:
* stage окружение должно поднимать каждый компонент приложения в одном экземпляре;
* production окружение — каждый компонент в трёх экземплярах;
* для production окружения нужно добавить endpoint на внешний адрес.

## Ответ

### Установка qbec
```bash
[olga@fedora Downloads]$ wget https://github.com/splunk/qbec/releases/download/v0.15.2/qbec-linux-amd64.tar.gz 
[olga@fedora Downloads]$ tar xf qbec-linux-amd64.tar.gz
[olga@fedora Downloads]$ sudo mv ./qbec /usr/local/bin/
```

### Создание
Для преобразования yaml в jsonnet использован ресурс [https://jsonnet.org/articles/kubernetes.html](https://jsonnet.org/articles/kubernetes.html).  

```bash
# Создание конфигурации
[olga@fedora 13-kubernetes-config-05-qbec]$ qbec init myapp --with-example
using server URL "https://192.168.56.50:6443" and default namespace "test" for the default environment
wrote myapp/params.libsonnet
wrote myapp/environments/base.libsonnet
wrote myapp/environments/default.libsonnet
wrote myapp/components/hello.jsonnet
wrote myapp/qbec.yaml
[olga@fedora 13-kubernetes-config-05-qbec]$ cd ./myapp
# Просмотр итоговых шаблонов (после заполнения всех данных в myapp)
[olga@fedora myapp]$ qbec show stage > ../stage.yaml
1 components evaluated in 5ms
[olga@fedora myapp]$ qbec show production > ../production.yaml
4 components evaluated in 5ms
# Деплой
[olga@fedora myapp]$ qbec apply stage --wait-all --yes
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
setting context to app1
setting context to app2
cluster metadata load took 26ms
1 components evaluated in 6ms

will synchronize 2 object(s)

1 components evaluated in 3ms
create deployments fullstack -n test (source fullstack)
create services fullstack -n test (source fullstack)
waiting for deletion list to be returned
server objects load took 608ms
---
stats:
  created:
  - deployments fullstack -n test (source fullstack)
  - services fullstack -n test (source fullstack)

waiting for readiness of 1 objects
  - deployments fullstack -n test

  0s    : deployments fullstack -n test :: 0 of 1 updated replicas are available
✓ 2s    : deployments fullstack -n test :: successfully rolled out (0 remaining)

✓ 2s: rollout complete
command took 2.86s
[olga@fedora myapp]$ qbec apply production --wait-all --yes
setting cluster to cluster.local
setting context to app1
setting context to app2
setting context to kubernetes-admin@cluster.local
cluster metadata load took 25ms
4 components evaluated in 11ms

will synchronize 7 object(s)

4 components evaluated in 5ms
create endpoints external-svc -n test (source ext_endpoint)
create persistentvolumeclaims prod-pvc -n test (source pvc)
create deployments backend -n test (source backend)
create deployments frontend -n test (source frontend)
create services backend -n test (source backend)
create services external-svc -n test (source ext_endpoint)
create services frontend -n test (source frontend)
server objects load took 1.004s
---
stats:
  created:
  - endpoints external-svc -n test (source ext_endpoint)
  - persistentvolumeclaims prod-pvc -n test (source pvc)
  - deployments backend -n test (source backend)
  - deployments frontend -n test (source frontend)
  - services backend -n test (source backend)
  - services external-svc -n test (source ext_endpoint)
  - services frontend -n test (source frontend)

waiting for readiness of 2 objects
  - deployments backend -n test
  - deployments frontend -n test

  0s    : deployments backend -n test :: 0 of 3 updated replicas are available
  0s    : deployments frontend -n test :: 0 of 3 updated replicas are available
  1s    : deployments frontend -n test :: 1 of 3 updated replicas are available
  3s    : deployments frontend -n test :: 2 of 3 updated replicas are available
✓ 3s    : deployments frontend -n test :: successfully rolled out (1 remaining)
  4s    : deployments backend -n test :: 1 of 3 updated replicas are available
  4s    : deployments backend -n test :: 2 of 3 updated replicas are available
✓ 9s    : deployments backend -n test :: successfully rolled out (0 remaining)

✓ 9s: rollout complete
command took 11.7s
```

### Проверка
Созданные объекты:  
```bash
[olga@fedora 13-kubernetes-config-05-qbec]$ kubectl get all
NAME                                      READY   STATUS       RESTARTS   AGE
pod/backend-7fc67ff8b9-5g4rl              1/1     Running      0          73s
pod/backend-7fc67ff8b9-68qt5              1/1     Running      0          73s
pod/backend-7fc67ff8b9-r64cp              1/1     Running      0          73s
pod/frontend-5fb755948-npnkf              1/1     Running      0          72s
pod/frontend-5fb755948-r4s5s              1/1     Running      0          72s
pod/frontend-5fb755948-z4d84              1/1     Running      0          72s
pod/fullstack-66bdd57f56-mq5xz            2/2     Running      0          2m56s
pod/nfs-server-nfs-server-provisioner-0   1/1     Running      0          2m55s
pod/postgres-sts-0                        1/1     Running      0          5m41s

NAME                                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                                                     AGE
service/backend                             ClusterIP   10.233.32.14    <none>        9000/TCP                                                                                                    71s
service/external-svc                        ClusterIP   None            <none>        80/TCP                                                                                                      71s
service/frontend                            NodePort    10.233.42.133   <none>        80:32182/TCP                                                                                                71s
service/fullstack                           NodePort    10.233.32.49    <none>        80:32183/TCP                                                                                                13m
service/nfs-server-nfs-server-provisioner   ClusterIP   10.233.41.139   <none>        2049/TCP,2049/UDP,32803/TCP,32803/UDP,20048/TCP,20048/UDP,875/TCP,875/UDP,111/TCP,111/UDP,662/TCP,662/UDP   11d
service/postgres-headless-svc               ClusterIP   None            <none>        5432/TCP                                                                                                    12d

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend     3/3     3            3           73s
deployment.apps/frontend    3/3     3            3           73s
deployment.apps/fullstack   1/1     1            1           13m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-7fc67ff8b9     3         3         3       73s
replicaset.apps/frontend-5fb755948     3         3         3       73s
replicaset.apps/fullstack-66bdd57f56   1         1         1       13m

NAME                                                 READY   AGE
statefulset.apps/nfs-server-nfs-server-provisioner   1/1     11d
statefulset.apps/postgres-sts                        1/1     12d
```

Проверка endpoint на внешний адрес:  
```bash
[olga@fedora 13-kubernetes-config-05-qbec]$ kubectl run -it --rm --image=alpine:latest --restart=Never -- bash
If you don't see a command prompt, try pressing enter.
/ # apk --update add curl
fetch https://dl-cdn.alpinelinux.org/alpine/v3.15/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.15/community/x86_64/APKINDEX.tar.gz
(1/5) Installing ca-certificates (20211220-r0)
(2/5) Installing brotli-libs (1.0.9-r5)
(3/5) Installing nghttp2-libs (1.46.0-r0)
(4/5) Installing libcurl (7.80.0-r0)
(5/5) Installing curl (7.80.0-r0)
Executing busybox-1.34.1-r5.trigger
Executing ca-certificates-20211220-r0.trigger
OK: 8 MiB in 19 packages
/ # curl -H 'Host: cat-fact.herokuapp.com' external-svc/facts/random?animal_type=cat
{"status":{"verified":null,"sentCount":0},"_id":"61d36272403b4002d3798703","user":"61b8566766b26cede617b4ef","text":"35342r54235233.","type":"cat","deleted":false,"createdAt":"2022-01-03T20:54:10.612Z","updatedAt":"2022-01-03T20:54:10.612Z","__v":0}
```

Приложение qbec - [myapp](./myapp)  
Сгенерированный шаблон для stage - [stage.yaml](stage.yaml)  
Сгенерированный шаблон для production - [production.yaml](production.yaml)  

