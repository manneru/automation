resource "aws_security_group" "lb-sg" {
  name        = "allow_enduser"
  description = "Allow enduser"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "enduser"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage-lb-sg"
  }
}



resource "aws_lb" "app-lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  #enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "alb-tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path = "/index.html"
    port = 80
    healthy_threshold   = 10
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 6
  }
  #path = "HTTP"
}

resource "aws_lb_listener" "alb-http" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "alb" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = aws_instance.apache.id
  port             = 80
}


