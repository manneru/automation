

resource "aws_security_group" "application-sg" {
  name        = "alb"
  description = "allow alb"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "alb-ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion-sg.id]
  }
  ingress {
    description      = "httpd for enduser"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
    #cider_block  = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage-application-sg"
  }
}


resource "aws_instance" "apache" {
ami           = "ami-06489866022e12a14"
instance_type = "t2.micro"
security_groups = [aws_security_group.application-sg.id] 
subnet_id  = aws_subnet.public[0].id
associate_public_ip_address = true
key_name = aws_key_pair.demo.id
user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo yum install httpd -y
  sudo yum update httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "*** Completed Installing apache2"
  EOF

tags = {
  Name = "app1"
}

}
  


