locals {
  common_tags = {
    Owner   = "oribm",
    Purpose = "whiskey"
  }

}
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}


resource "aws_default_vpc" "default" {

}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "firstwhiskey" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  ebs_block_device {
          device_name           =  "/dev/sda1"
          encrypted             = true
          volume_size           = 10
          volume_type           = "gp2" 
  }
  root_block_device {
          volume_size           = 10
          volume_type           = "gp2"
  }

 tags = merge(local.common_tags, { Name = "firstwhiskey" })

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "sudo rm /usr/share/nginx/html/index.html",
      "echo <html>
<header><title>This is title</title></header>
<body>
Welcome to Grandpa's Whiskey
</body>
</html>
 > /usr/share/nginx/html/index.html"
    ]
  }
}


resource "aws_instance" "secondwhiskey" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }


  ebs_block_device {
          device_name           =  "/dev/sda1"
          encrypted             = true
          volume_size           = 10
          volume_type           = "gp2" 
  }
  root_block_device {
          volume_size           = 10
          volume_type           = "gp2"
  }

  tags = merge(local.common_tags, { Name = "secondwhiskey" })

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "sudo rm /usr/share/nginx/html/index.html",
      "echo <html>
<header><title>This is title</title></header>
<body>
Welcome to Grandpa's Whiskey
</body>
</html>
 > /usr/share/nginx/html/index.html"
    ]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "nginx"
  description = "Allow ssh for nginx"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
