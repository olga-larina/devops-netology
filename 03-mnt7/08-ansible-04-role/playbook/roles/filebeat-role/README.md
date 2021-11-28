filebeat-role
=========

Роль для установки filebeat на хостах с ОС: Debian, Ubuntu, CentOS, RHEL.

Requirements
------------

Поддерживаются только следующие ОС: Debian, Ubuntu, CentOS, RHEL.

Role Variables
--------------

| Variable name | Default | Description |
|-----------------------|----------|-------------------------|
| filebeat_version | "7.14.0" | Параметр, который определяет, какой версии filebeat будет установлен |

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: filebeat-role }

License
-------

MIT

Author Information
------------------

Olga Ivanova, devops-10
