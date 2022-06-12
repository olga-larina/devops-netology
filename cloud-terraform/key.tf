# 15.3

# Ключ KMS
resource "yandex_kms_symmetric_key" "key-netology" {
  name              = "netology-symetric-key"
  description       = "key for cat storage"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}