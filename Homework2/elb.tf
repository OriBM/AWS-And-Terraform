resource "aws_elb" "web" {
  name = "elb"
  subnets         = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  security_groups = [aws_security_group.allow_ssh.id]
  instances       = [aws_instance.web-server[0].id, aws_instance.web-server[1].id]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  tags = merge(local.common_tags, { Name = "elb" })

}