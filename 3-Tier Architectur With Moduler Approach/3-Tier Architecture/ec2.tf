

resource "aws_instance" "web" {
  ami           = "ami-0a72af05d27b49ccb"
  instance_type = "t2.micro"
  key_name = "my_key_pair"
  subnet_id = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
  count = 2

  tags = {
    Name = "WebServer"
  }

  provisioner "file" {
    source = "./my_key_pair.pub"
    destination = "/home/ec2-user/my_key_pair.pub"
  
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("./my_key_pair")}"
    }  
  }

}

resource "aws_instance" "db" {
  ami           = "ami-0a72af05d27b49ccb"
  instance_type = "t2.micro"
  key_name = "my_key_pair"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_tls_db.id]

  tags = {
    Name = "DB Server"
  }
}