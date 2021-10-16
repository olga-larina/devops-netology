provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "netology" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.small"
  count                = 2
  cpu_core_count       = 1
  cpu_threads_per_core = 1
  availability_zone    = "ap-south-1"
  hibernation          = true
  monitoring           = true

  tags = {
    Name = "NetologyApp"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}