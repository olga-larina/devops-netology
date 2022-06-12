# 15.1

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