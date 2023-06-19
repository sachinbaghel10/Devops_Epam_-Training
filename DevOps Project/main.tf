#Creating a vpc
resource "aws_vpc" "DevOps_Project_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "DevOps_Project_vpc"
  }
}

#Creating subnet private and public
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.DevOps_Project_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.DevOps_Project_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}

# creating a security group
resource "aws_security_group" "DevOps_Project_SG" {
  name        = "DevOps_Project_SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.DevOps_Project_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps_Project_SG"
  }
}

#Creating internet Gateway
resource "aws_internet_gateway" "DevOps_Project_IGW" {
  vpc_id = aws_vpc.DevOps_Project_vpc.id

  tags = {
    Name = "DevOps_Project_IGW"
  }
}
#Creating route table that should be public
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.DevOps_Project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevOps_Project_IGW.id
  }

  tags = {
    Name = "Public_Route_Table"
  }
}
#route table association
#Provides a resource to create an association between a route
#table and a subnet or a route table and an internet gateway or
#virtual private gateway.
resource "aws_route_table_association" "Public_RT_Association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public_Route_Table.id
}

#Creating a web Server 
resource "aws_instance" "Dev_Web_Server" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  key_name      = "DevOps_Project_Key"
  subnet_id     =  aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.DevOps_Project_SG.id]
connection {
    type      = "ssh"
    host      = self.public-ip
    user      = ec2-user
    private_key = file("./DevOps_Project_Key.pem")
}
 tags = {
  Name = "Web_Server"
 }
}

#Creating Elastic ip for web server or ec2 instance
resource "aws_eip" "DevOps_Project_EIP" {
  instance = aws_instance.Dev_Web_Server.id
  vpc      = true
}

#creating Data Base Server
resource "aws_instance" "Pro_DB_Server" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  key_name      = "DevOps_Project_Key"
  subnet_id     =  aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.DevOps_Project_SG.id]
connection {
    type      = "ssh"
   # host      = self.public-ip
    user      = ec2-user
    private_key = file("./DevOps_Project_Key.pem")
}
 tags = {
  Name = "Pro_Server"
 }
}

#Creating Elastic ip for web server or ec2 instance
resource "aws_eip" "DevOps_Project_aws_ngw_id" {
 # instance = aws_instance.Web_Server.id
  vpc      = true
}
#nat gatway
resource "aws_nat_gateway" "DevOps_Project_aws_ngw_id" {
  allocation_id = aws_eip.DevOps_Project_aws_ngw_id.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT Gateway"
  }
}

#route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.DevOps_Project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.DevOps_Project_aws_ngw_id.id
  }

  tags = {
    Name = "Private_Route_Table"
  }
}
#route table association
resource "aws_route_table_association" "Private_RT_asso" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
