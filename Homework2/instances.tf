resource "aws_instance" "web-server" {
  count = var.number_of_nginx_instances
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  ami                         = data.aws_ami.aws-linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  user_data                   = local.my-instance-userdata


  tags = merge(local.common_tags, {
    Name = "ec2-web-servers-${count.index}"
  })
}

resource "aws_instance" "db" {
  count = var.number_of_nginx_instances
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  ami                         = data.aws_ami.aws-linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }
  tags = merge(local.common_tags, {
    Name = "ec2-dbs-${count.index}"
  })
}