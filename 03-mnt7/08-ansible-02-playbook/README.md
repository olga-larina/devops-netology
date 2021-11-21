# Olga Ivanova, devops-10. Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соответствии с группами из предподготовленного playbook. 
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.

См. [prod.yml](./playbook/inventory/prod.yml), [kibana/vars.yml](./playbook/group_vars/kibana/vars.yml), [templates/kib.sh.j2](./playbook/templates/kib.sh.j2).  
Подключение будет к `docker`, версия `kibana` такая же, как у `elasticsearch`.  
Запускаем контейнеры:
```bash
[olga@fedora bin]$ docker run -d --name ki pycontribs/ubuntu sleep 1000000000
[olga@fedora bin]$ docker run -d --name el pycontribs/ubuntu sleep 1000000000
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.

См. [site.yml](./playbook/site.yml), `Install Kibana`

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Были предупреждения `risky-file-permissions: File permissions unset or incorrect`. Поэтому добавила `mode: 0644` (т.е. `-rw-rw-rw-`).

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```bash
[olga@fedora playbook]$ ansible-playbook site.yml -i inventory/prod.yml --check
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Java] ********************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ki should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will 
default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [ki]
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host el should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will 
default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [el]

TASK [Set facts for Java 11 vars] ******************************************************************************************************************************************************************************
ok: [el]
ok: [ki]

TASK [Upload .tar.gz file containing binaries from local storage] **********************************************************************************************************************************************
changed: [ki]
changed: [el]

TASK [Ensure installation dir exists] **************************************************************************************************************************************************************************
changed: [ki]
changed: [el]

TASK [Extract java in the installation directory] **************************************************************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [el]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.13' must be an existing dir"}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [ki]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.13' must be an existing dir"}

PLAY RECAP *****************************************************************************************************************************************************************************************************
el                         : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
ki                         : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0  
```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

Проверка:  
```bash
[olga@fedora ~]$ docker exec -it ki bash
root@e72eda7d0827:/# cd /opt
root@e72eda7d0827:/opt# ls
jdk  kibana
root@e72eda7d0827:/opt# exit
exit
[olga@fedora ~]$ docker exec -it el bash
root@9809582a53e3:/# cd /opt
root@9809582a53e3:/opt# ls
elastic  jdk
```

Запуск:  
```bash
[olga@fedora playbook]$ ansible-playbook site.yml -i inventory/prod.yml --diff
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Java] ********************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ki should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will 
default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [ki]
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host el should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will 
default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [el]

TASK [Set facts for Java 11 vars] ******************************************************************************************************************************************************************************
ok: [el]
ok: [ki]

TASK [Upload .tar.gz file containing binaries from local storage] **********************************************************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [ki]
diff skipped: source file size is greater than 104448
changed: [el]

TASK [Ensure installation dir exists] **************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/jdk/11.0.13",
-    "state": "absent"
+    "state": "directory"
 }

changed: [ki]
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/jdk/11.0.13",
-    "state": "absent"
+    "state": "directory"
 }

changed: [el]

TASK [Extract java in the installation directory] **************************************************************************************************************************************************************
changed: [ki]
changed: [el]

TASK [Export environment variables] ****************************************************************************************************************************************************************************
--- before
+++ after: /home/olga/.ansible/tmp/ansible-local-63265430nljjd/tmpuussrhda/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.13
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [el]
--- before
+++ after: /home/olga/.ansible/tmp/ansible-local-63265430nljjd/tmpzrk5gptj/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.13
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [ki]

PLAY [Install Elasticsearch] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [el]

TASK [Upload tar.gz Elasticsearch from remote URL] *************************************************************************************************************************************************************
changed: [el]

TASK [Create directrory for Elasticsearch] *********************************************************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/elastic/7.10.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [el]

TASK [Extract Elasticsearch in the installation directory] *****************************************************************************************************************************************************
changed: [el]

TASK [Set environment Elastic] *********************************************************************************************************************************************************************************
--- before
+++ after: /home/olga/.ansible/tmp/ansible-local-63265430nljjd/tmpzl_2auwd/elk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/elastic/7.10.1
+export PATH=$PATH:$ES_HOME/bin
\ No newline at end of file

changed: [el]

PLAY [Install Kibana] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [ki]

TASK [Upload tar.gz Kibana from remote URL] ********************************************************************************************************************************************************************
changed: [ki]

TASK [Create directory for Kibana] *****************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/kibana/7.10.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [ki]

TASK [Extract Kibana in the installation directory] ************************************************************************************************************************************************************
changed: [ki]

TASK [Set environment Kibana] **********************************************************************************************************************************************************************************
--- before
+++ after: /home/olga/.ansible/tmp/ansible-local-63265430nljjd/tmp56ohh6io/kib.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KI_HOME=/opt/kibana/7.10.1
+export PATH=$PATH:$KI_HOME/bin
\ No newline at end of file

changed: [ki]

PLAY RECAP *****************************************************************************************************************************************************************************************************
el                         : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ki                         : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```bash
[olga@fedora playbook]$ ansible-playbook site.yml -i inventory/prod.yml --diff
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print incorrect line lengths

PLAY [Install Java] ********************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ki should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will 
default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [ki]
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host el should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will 
default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be 
removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [el]

TASK [Set facts for Java 11 vars] ******************************************************************************************************************************************************************************
ok: [el]
ok: [ki]

TASK [Upload .tar.gz file containing binaries from local storage] **********************************************************************************************************************************************
ok: [ki]
ok: [el]

TASK [Ensure installation dir exists] **************************************************************************************************************************************************************************
ok: [el]
ok: [ki]

TASK [Extract java in the installation directory] **************************************************************************************************************************************************************
skipping: [el]
skipping: [ki]

TASK [Export environment variables] ****************************************************************************************************************************************************************************
ok: [ki]
ok: [el]

PLAY [Install Elasticsearch] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [el]

TASK [Upload tar.gz Elasticsearch from remote URL] *************************************************************************************************************************************************************
ok: [el]

TASK [Create directrory for Elasticsearch] *********************************************************************************************************************************************************************
ok: [el]

TASK [Extract Elasticsearch in the installation directory] *****************************************************************************************************************************************************
skipping: [el]

TASK [Set environment Elastic] *********************************************************************************************************************************************************************************
ok: [el]

PLAY [Install Kibana] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************************************
ok: [ki]

TASK [Upload tar.gz Kibana from remote URL] ********************************************************************************************************************************************************************
ok: [ki]

TASK [Create directory for Kibana] *****************************************************************************************************************************************************************************
ok: [ki]

TASK [Extract Kibana in the installation directory] ************************************************************************************************************************************************************
skipping: [ki]

TASK [Set environment Kibana] **********************************************************************************************************************************************************************************
ok: [ki]

PLAY RECAP *****************************************************************************************************************************************************************************************************
el                         : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
ki                         : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0 
```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

См. [README.md](playbook/README.md)

10 Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.