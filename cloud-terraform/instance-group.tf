# 15.2

# Группа с 3 ВМ и шаблоном LAMP, целевой группой для network load balancer
resource "yandex_compute_instance_group" "lamp" {
  name                = "lamp-ig"
  folder_id           = local.folder_id
  service_account_id  = yandex_iam_service_account.ig-sa.id
  deletion_protection = false # без запрета на удаление (иначе перед удалением потребуется снять защиту в UI)
  instance_template {
    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    scheduling_policy {
      preemptible = true # прерываемые
    }
    network_interface {
      network_id = yandex_vpc_network.netology.id
      subnet_ids = [yandex_vpc_subnet.public.id]
    }
    # Скрипт для инициализации + стартовая страница с картинкой
    metadata = {
      user-data = "#!/bin/bash\nyum install httpd -y\nservice httpd start\nchkconfig httpd on\ncd /var/www/html\necho \"<html><h1>My cool web-server</h1><img src=\"https://storage.yandexcloud.net/olga-ivanova-12062022/cat\"></html>\" > index.html"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3 # количество инстансов
    }
  }

  # распределение по зонам
  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }


  # проверка состояния ВМ
  max_checking_health_duration = 10
  health_check {
    interval = 5
    timeout = 1
    healthy_threshold = 3
    unhealthy_threshold = 3
    http_options {
      path = "/index.html"
      port = 80
    }
  }

  # Целевая группа для сетевого балансировщика
  load_balancer {
    target_group_name        = "cat-target-group"
    target_group_description = "load balancer cat target group"
  }

  # добавлено
  depends_on = [yandex_iam_service_account.ig-sa, yandex_resourcemanager_folder_iam_binding.editor, yandex_resourcemanager_folder_iam_binding.vpc-user]
}