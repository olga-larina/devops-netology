# 15.2

# Бакет
resource "yandex_storage_bucket" "bucket-olga-ivanova-12062022" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "olga-ivanova-12062022"
  # 15.3 Шифрование содержимого
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-netology.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Картинка с доступом на чтение у всех
resource "yandex_storage_object" "cat-image" {
  bucket = yandex_storage_bucket.bucket-olga-ivanova-12062022.id
  key    = "cat"
  source = "/home/olga/Downloads/cat.jpg"
  acl    = "public-read"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}