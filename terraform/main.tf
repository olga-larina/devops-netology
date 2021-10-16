provider "aws" {
  region = "ap-south-1"
  skip_requesting_account_id  = true
  skip_credentials_validation = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

# Not working without credentials
#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["099720109477"] # Canonical
#}

locals {
  netology_ami = "ami-046d87fab2e550dbc"
  netology_instance_type_map = {
    stage = "t3.small"
    prod  = "t3.large"
  }
  netology_instance_count_map = {
    stage = 1
    prod  = 2
  }
  netology_instance_name_map = {
    stage = toset(["first"])
    prod  = toset(["first", "second"])
  }
}

resource "aws_instance" "netology" {
  ami                  = local.netology_ami
  instance_type        = local.netology_instance_type_map[terraform.workspace]
  count                = local.netology_instance_count_map[terraform.workspace]
  cpu_core_count       = 1
  cpu_threads_per_core = 1
  availability_zone    = "ap-south-1"
  hibernation          = true
  monitoring           = true

  tags = {
    Name = "NetologyApp"
  }
}

resource "aws_instance" "netology2" {
  for_each = local.netology_instance_name_map[terraform.workspace]

  ami                  = local.netology_ami
  instance_type        = local.netology_instance_type_map[terraform.workspace]
  availability_zone    = "ap-south-1"

  tags = {
    Name = "NetologyApp2-${each.key}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Not working without credentials
#data "aws_caller_identity" "current" {}

data "aws_region" "current" {}