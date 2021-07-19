# Olga Ivanova, devops-10. Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

Ответ: Изучено.  

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Ответ:  
Не могут. "Жёсткая" ссылка - это структурная составляющая файла. Все такие ссылки одного файла равноправны и неотличимы друг от друга,
имеют один и тот же inode. Их количество хранится в метаинформации. Файлы с нулевым количеством ссылок перестают существовать для системы.  
Т.к. все "жёсткие" ссылки по сути являются одним и тем же объектом (имеют один inode), разные права доступа и владельца они иметь не могут.  
Пример:  
```bash
vagrant@vagrant:~$ touch test_file
vagrant@vagrant:~$ ln test_file hardlink1
vagrant@vagrant:~$ ln test_file hardlink2
vagrant@vagrant:~$ ls -li
total 0
131084 -rw-rw-r-- 3 vagrant vagrant 0 Jul  6 09:55 hardlink1
131084 -rw-rw-r-- 3 vagrant vagrant 0 Jul  6 09:55 hardlink2
131084 -rw-rw-r-- 3 vagrant vagrant 0 Jul  6 09:55 test_file
vagrant@vagrant:~$ sudo chown root hardlink1; sudo chmod g-w hardlink2
vagrant@vagrant:~$ ls -li
total 0
131084 -rw-r--r-- 3 root vagrant 0 Jul  6 09:55 hardlink1
131084 -rw-r--r-- 3 root vagrant 0 Jul  6 09:55 hardlink2
131084 -rw-r--r-- 3 root vagrant 0 Jul  6 09:55 test_file
```  
Видим, что при изменении прав и владельца они меняются везде.  
 
3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

   Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

Ответ:  
```bash
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
└─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
sdc                    8:32   0  2.5G  0 disk
```  

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

Ответ:  
```bash
root@vagrant:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x4c8465ce.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-5242879, default 2048): 2048
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n           
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 2
First sector (4196352-5242879, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): 

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): p       
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x4c8465ce

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk 
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part 
└─sda5                 8:5    0 63.5G  0 part 
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk 
├─sdb1                 8:17   0    2G  0 part 
└─sdb2                 8:18   0  511M  0 part 
sdc                    8:32   0  2.5G  0 disk
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

Ответ:
```bash
root@vagrant:~# sfdisk -d /dev/sdb | sfdisk --force /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x4c8465ce.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x4c8465ce

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk 
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part 
└─sda5                 8:5    0 63.5G  0 part 
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk 
├─sdb1                 8:17   0    2G  0 part 
└─sdb2                 8:18   0  511M  0 part 
sdc                    8:32   0  2.5G  0 disk 
├─sdc1                 8:33   0    2G  0 part 
└─sdc2                 8:34   0  511M  0 part
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

Ответ:
```bash
root@vagrant:~# mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

Ответ:
```bash
root@vagrant:~# mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

Ответ:
```bash
root@vagrant:~# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:~# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
```

9. Создайте общую volume-group на этих двух PV.

Ответ:
```bash
root@vagrant:~# vgcreate vg_md /dev/md0 /dev/md1
  Volume group "vg_md" successfully created
root@vagrant:~# pvs
  PV         VG        Fmt  Attr PSize    PFree   
  /dev/md0   vg_md     lvm2 a--  1016.00m 1016.00m
  /dev/md1   vg_md     lvm2 a--    <2.00g   <2.00g
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0 
root@vagrant:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree 
  vg_md       2   0   0 wz--n-  <2.99g <2.99g
  vgvagrant   1   2   0 wz--n- <63.50g     0
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

Ответ:
```bash
root@vagrant:~# lvcreate --name lv_md --size 100m --verbose vg_md /dev/md0
  Archiving volume group "vg_md" metadata (seqno 1).
  Creating logical volume lv_md
  Creating volume group backup "/etc/lvm/backup/vg_md" (seqno 2).
  Activating logical volume vg_md/lv_md.
  activation/volume_list configuration setting not defined: Checking only host tags for vg_md/lv_md.
  Creating vg_md-lv_md
  Loading table for vg_md-lv_md (253:2).
  Resuming vg_md-lv_md (253:2).
  Wiping known signatures on logical volume "vg_md/lv_md"
  Initializing 4.00 KiB of logical volume "vg_md/lv_md" with value 0.
  Logical volume "lv_md" created.
root@vagrant:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  vg_md       2   1   0 wz--n-  <2.99g 2.89g
  vgvagrant   1   2   0 wz--n- <63.50g    0 
root@vagrant:~# lvs
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv_md  vg_md     -wi-a----- 100.00m                                                    
  root   vgvagrant -wi-ao---- <62.54g                                                    
  swap_1 vgvagrant -wi-ao---- 980.00m  
```

11. Создайте `mkfs.ext4` ФС на получившемся LV.

Ответ:
```bash
root@vagrant:~# mkfs.ext4 /dev/vg_md/lv_md
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

Ответ:
```bash
root@vagrant:~# mkdir /tmp/new
root@vagrant:~# mount /dev/vg_md/lv_md /tmp/new
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

Ответ:
```bash
root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2021-07-06 10:59:25--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 20992385 (20M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz            100%[=========================================>]  20.02M  4.87MB/s    in 4.6s    

2021-07-06 10:59:29 (4.39 MB/s) - ‘/tmp/new/test.gz’ saved [20992385/20992385]
```

14. Прикрепите вывод `lsblk`.

Ответ:
```bash
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1 
└─sdb2                 8:18   0  511M  0 part  
  └─md0                9:0    0 1018M  0 raid0 
    └─vg_md-lv_md    253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1 
└─sdc2                 8:34   0  511M  0 part  
  └─md0                9:0    0 1018M  0 raid0 
    └─vg_md-lv_md    253:2    0  100M  0 lvm   /tmp/new
```

15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

Ответ:  
Выполнено.  
```bash
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

Ответ:
```bash
root@vagrant:~# pvmove /dev/md0 /dev/md1
  /dev/md0: Moved: 48.00%
  /dev/md0: Moved: 100.00%
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1 
│   └─vg_md-lv_md    253:2    0  100M  0 lvm   /tmp/new
└─sdb2                 8:18   0  511M  0 part  
  └─md0                9:0    0 1018M  0 raid0 
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1 
│   └─vg_md-lv_md    253:2    0  100M  0 lvm   /tmp/new
└─sdc2                 8:34   0  511M  0 part  
  └─md0                9:0    0 1018M  0 raid0
```

17. Сделайте `--fail` на устройство в вашем RAID1 md.

Ответ:
```bash
root@vagrant:~# mdadm /dev/md1 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md1
root@vagrant:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md1 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
```

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

Ответ:
```bash
root@vagrant:~# dmesg | grep md1
[ 1879.532742] md/raid1:md1: not clean -- starting background reconstruction
[ 1879.532747] md/raid1:md1: active with 2 out of 2 mirrors
[ 1879.532789] md1: detected capacity change from 0 to 2144337920
[ 1879.536910] md: resync of RAID array md1
[ 1889.673448] md: md1: resync done.
[ 4039.092040] md/raid1:md1: Disk failure on sdb1, disabling device.
               md/raid1:md1: Operation continuing on 1 devices.
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

Ответ:  
Выполнено.
```bash
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```

20. Погасите тестовый хост, `vagrant destroy`.

Ответ: Выполнено.