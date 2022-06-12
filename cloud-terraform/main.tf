# Базовые настройки
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

locals {
  folder_id = "b1gcefcbnh0ok32bkvif"
}

provider "yandex" {
  cloud_id  = "b1go6ie337pf2l92gurj"
  folder_id = local.folder_id
  zone      = "ru-central1-a"
}
