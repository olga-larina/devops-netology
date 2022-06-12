# 15.1

# Таблица маршрутизации
resource "yandex_vpc_route_table" "route-table-nat" {
  network_id = yandex_vpc_network.netology.id

  static_route {
    destination_prefix = "0.0.0.0/0" # весь трафик
    next_hop_address   = yandex_compute_instance.nat-vm.network_interface[0].ip_address # направляется на NAT инстанс
  }
}