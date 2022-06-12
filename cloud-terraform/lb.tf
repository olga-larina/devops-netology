# 15.2

# Сетевой балансировщик
resource "yandex_lb_network_load_balancer" "cat-lb" {
  name = "cat-load-balancer"

  listener {
    name = "cat-listener"
    port = 80
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}