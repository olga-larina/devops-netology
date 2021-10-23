module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name    = "netology"

  ami                    = "ami-ebd02392"
  instance_type          = "t2.small"
  hibernation            = true
  monitoring             = true
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"
  availability_zone      = "ap-south-1"
  cpu_core_count         = 1
  cpu_threads_per_core   = 1

  tags = {
    Name        = "NetologyApp"
    Terraform   = "true"
    Environment = "dev"
  }
}