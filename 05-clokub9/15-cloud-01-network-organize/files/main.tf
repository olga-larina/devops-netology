# Базовые настройки
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id  = "b1go6ie337pf2l92gurj"
  folder_id = "b1gcefcbnh0ok32bkvif"
  zone      = "ru-central1-a"
}

# VPC
resource "yandex_vpc_network" "netology" {
  name = "netology-network"
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# NAT instance
resource "yandex_compute_instance" "nat-vm" {
  name = "nat-vm-instance"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true # для публичного адреса
  }

  metadata = {
    ssh-keys = "my_key:${file("~/.ssh/id_rsa_ya.pub")}"
  }
}

# VM с публичным IP
resource "yandex_compute_instance" "public-vm" {
  name = "public-vm-instance"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd89ovh4ticpo40dkbvd" # ubuntu
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true # для публичного адреса
  }

  metadata = {
    ssh-keys = "my_key:${file("~/.ssh/id_rsa_ya.pub")}"
  }
}

# Приватная подсеть
resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.route-table-nat.id # привязываем таблицу маршрутизации
}

# Таблица маршрутизации
resource "yandex_vpc_route_table" "route-table-nat" {
  network_id = yandex_vpc_network.netology.id

  static_route {
    destination_prefix = "0.0.0.0/0" # весь трафик
    next_hop_address   = yandex_compute_instance.nat-vm.network_interface[0].ip_address # направляется на NAT инстанс
  }
}

# VM без публичного IP
resource "yandex_compute_instance" "private-vm" {
  name = "private-vm-instance"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd89ovh4ticpo40dkbvd" # ubuntu
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id # приватная подсеть
    # без публичного IP
  }

  metadata = {
    ssh-keys = "my_key:${file("~/.ssh/id_rsa_ya.pub")}"
  }
}
