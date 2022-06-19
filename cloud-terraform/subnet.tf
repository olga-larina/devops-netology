# 15.1

# Публичная подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Приватная подсеть
resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.route-table-nat.id # привязываем таблицу маршрутизации
}

# 15.4

# Приватные подсети

resource "yandex_vpc_subnet" "private2" {
  name           = "private-subnet-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.21.0/24"]
}

resource "yandex_vpc_subnet" "private3" {
  name           = "private-subnet-3"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.22.0/24"]
}

# Публичные подсети

resource "yandex_vpc_subnet" "public2" {
  name           = "public-subnet-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_vpc_subnet" "public3" {
  name           = "public-subnet-3"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}