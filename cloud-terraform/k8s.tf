# 15.4

# Кластер k8s
resource "yandex_kubernetes_cluster" "regional_cluster_k8s" {
  network_id = yandex_vpc_network.netology.id

  # Региональный мастер с размещением нод в разных 3 подсетях
  master {
    public_ip = true # чтобы были публичные адреса
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public.zone
        subnet_id = yandex_vpc_subnet.public.id
      }

      location {
        zone      = yandex_vpc_subnet.public2.zone
        subnet_id = yandex_vpc_subnet.public2.id
      }

      location {
        zone      = yandex_vpc_subnet.public3.zone
        subnet_id = yandex_vpc_subnet.public3.id
      }
    }
  }

  # Сервисный аккаунт
  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id

  # возможность шифрования ключом из KMS
  kms_provider {
    key_id = yandex_kms_symmetric_key.key-netology.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}

# Группа узлов
resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id  = yandex_kubernetes_cluster.regional_cluster_k8s.id

  instance_template {
    platform_id = "standard-v2"

    nat = true # deprecated, использовать nat under network_interface (но не даёт создать одновременно с allocation_policy)

    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true # прерываемая
    }

    container_runtime {
      type = "docker"
    }
  }

  # Автомасштабирование от 3 до 6
  scale_policy {
    auto_scale {
      initial = 3
      max = 6
      min = 3
    }
  }

  # При автоматическом масштабировании доступно только одно расположение
  allocation_policy {
    location {
      zone      = yandex_vpc_subnet.public.zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }
}