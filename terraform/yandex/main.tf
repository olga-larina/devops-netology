provider "yandex" {
  token     = "OAuth_token"
  cloud_id  = "cloud-id"
  folder_id = "folder-id"
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-1804-lts"
}

resource "yandex_compute_instance" "netology" {
  name = "mynetology"
  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.ubuntu.id}"
      size     = 4
    }
  }
  network_interface {
    subnet_id = "subnet_id"
  }
  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }
}