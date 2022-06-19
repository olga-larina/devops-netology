# 15.4

#- Создать БД с именем `netology_db` c логином и паролем
# Кластер MySQL
resource "yandex_mdb_mysql_cluster" "mysql" {
  name        = "mysql_cluster"
  environment = "PRESTABLE"
  version     = "8.0"
  network_id  = yandex_vpc_network.netology.id
  deletion_protection = true # защита кластера от непреднамеренного удаления

  resources {
    resource_preset_id = "b1.medium" # что соответствует платформе Intel Broadwell с производительностью 50% CPU согласно https://cloud.yandex.com/en/docs/managed-mysql/concepts/instance-types
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  # ноды кластера в разных подсетях
  # High availability group - node-1 + node-2; replica - node-3
  host {
    zone      = yandex_vpc_subnet.private.zone
    subnet_id = yandex_vpc_subnet.private.id
    name      = "node-1"
  }

  host {
    zone      = yandex_vpc_subnet.private2.zone
    subnet_id = yandex_vpc_subnet.private2.id
    name      = "node-2"
  }

  host {
    zone      = yandex_vpc_subnet.private3.zone
    subnet_id = yandex_vpc_subnet.private3.id
    name      = "node-3"
    replication_source_name = "node-1"
  }

  # произвольное время технического обслуживания
  maintenance_window {
    type = "ANYTIME"
  }

  # время начала резервного копирования
  backup_window_start {
    hours   = 23
    minutes = 59
  }
}

# БД
resource "yandex_mdb_mysql_database" "mysql_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology_db"
}

# Пользователь
resource "yandex_mdb_mysql_user" "netuser" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netuser"
  password   = "password"

  permission {
    database_name = yandex_mdb_mysql_database.mysql_db.name
    roles         = ["ALL"]
  }
}