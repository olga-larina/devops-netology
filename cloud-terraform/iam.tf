# 15.2

# Сервисный аккаунт для работы с бакетом
resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "sa-storage-editor"
}

# Права на редактирование
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создание статического ключа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

# Сервисный аккаунт для работы с группами ВМ
resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "service account to manage IG"
}

# Права на редактирование ресурсов
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = local.folder_id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.ig-sa.id}",
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

# Права на использование ресурсов VPC (сетей, подсетей, маршрутов)
resource "yandex_resourcemanager_folder_iam_binding" "vpc-user" {
  folder_id = local.folder_id
  role      = "vpc.user"
  members   = ["serviceAccount:${yandex_iam_service_account.ig-sa.id}"]
}

# 15.4

# Сервисный аккаунт для работы с кластером и узлами k8s. Ему назначается роль editor и container-registry.images.puller
resource "yandex_iam_service_account" "k8s-sa" {
  name        = "k8s-sa"
  description = "service account to manage k8s cluster and nodes"
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  members   = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}