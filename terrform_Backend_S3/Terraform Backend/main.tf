# Create a VPC

resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc_cidr

     tags = {
    Name = var.vpc_name
  }
}