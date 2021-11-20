# Olga Ivanova, devops-10. Домашнее задание к занятию "08.01 Введение в Ansible"

1. Где расположен файл с `some_fact` из второго пункта задания?

Файл находится в [group_vars/all/examp.yml](group_vars/all/examp.yml).  
При запуске изначально получили значение `12`

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

```bash
ansible-playbook site.yml -i inventory/test.yml
```

3. Какой командой можно зашифровать файл?

```bash
ansible-vault encrypt group_vars/deb/examp.yml
```

4. Какой командой можно расшифровать файл?

```bash
ansible-vault decrypt group_vars/deb/examp.yml
```

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

```bash
ansible-vault view group_vars/deb/examp.yml
```

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

```bash
ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
```

7. Как называется модуль подключения к host на windows?

Это `winrm`. Команда для поиска:  
```bash
[olga@fedora playbook]$ ansible-doc -t connection -l | grep -i win
```

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

```bash
[olga@fedora playbook]$ ansible-doc -t connection -l | grep -i ssh
ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ss...
paramiko_ssh                   Run tasks via python ssh (paramiko)         
ssh                            connect via ssh client binary
```

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

Это `remote_user`. И есть несколько вариантов его определения:  
```bash
[olga@fedora playbook]$ ansible-doc -t connection ssh | grep -i user -C 10
- remote_user
        User name with which to login to the remote server, normally
        set by the remote_user keyword.
        If no user is supplied, Ansible will let the ssh client binary
        choose the user as it normally
        [Default: (null)]
        set_via:
          env:
          - name: ANSIBLE_REMOTE_USER
          ini:
          - key: remote_user
            section: defaults
          vars:
          - name: ansible_user
          - name: ansible_ssh_user
        
        cli:
        - name: user
```