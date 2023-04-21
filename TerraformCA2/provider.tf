provider "aws" {
access_key = "AKIAT66DWZQYUSVSIMWY"
secret_key = "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"
region = "us-east-1"
}



resource "aws_vpc" "exam" {
cidr_block = "10.0.0.0/16"

tags = {
Name = "exam"
}
}

# subnet in the VPC

resource "aws_subnet" "exam" {
vpc_id = aws_vpc.exam.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"

tags = {
Name = "exam-subnet"
}
}

# route table
resource "aws_route_table" "exam" {
vpc_id = aws_vpc.exam.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.exam.id
}

tags = {
Name = "exam-route-table"
}
}

#internet gateway
resource "aws_internet_gateway" "exam" {

vpc_id = aws_vpc.exam.id

tags = {
Name = "exam-internet-gateway"
}
}

# Associate the route table with the subnet
resource "aws_route_table_association" "exam" {
subnet_id = aws_subnet.exam.id
route_table_id = aws_route_table.exam.id
}

# Create an EC2 instance in the subnet
resource "aws_instance" "exam" {
ami = "ami-007855ac798b5175e"
instance_type = "t2.micro"
subnet_id = aws_subnet.exam.id
vpc_security_group_ids = [aws_security_group.exam.id]

tags = {
Name = "exam-instance"
}
}

# security group for the EC2 instance
resource "aws_security_group" "exam" {
name_prefix = "exam"
vpc_id = aws_vpc.exam.id

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "exam-security-group"
}
}

# ALB with a listener and target group
resource "aws_lb" "exam" {
name = "exam-lb"
load_balancer_type = "application"
subnets = [aws_subnet.exam.id]

tags = {
Name = "exam-lb"
}
}

resource "aws_lb_listener" "exam" {
load_balancer_arn = aws_lb.exam.arn
port = "80"
protocol = "HTTP"

default_action {
type = "forward"
target_group_arn = aws_lb_target_group.exam.arn
}
}

resource "aws_lb_target_group" "exam" {
name_prefix = "exam"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.exam.id
}