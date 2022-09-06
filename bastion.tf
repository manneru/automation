data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_key_pair" "demo" {
  key_name   = "demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXFRCvWLeHiv3BClfBew5kacwSe1zhntdVMbI3TD8hhu050fuPK2Jo5gVc3waEhQ74iVebjbugY3B0DBgdWYgvBOh1YEFtwBJKzAqEpMcu9mnKh0W/q+hfEmkYmQ7IyLkM0qa6mpJocs63qYln56JWlq9K8+pJLIdIeqDRLHULE3YKvilojBCjGZGztFS8OAf9PcVs71xaIHUkq9pPSKA8kVCPtDXE+JFtQFcf/AMOMRMH9kSHizLkSrfK2UoOdrzmKRyowjKCiqeDpnbifFqv6vesClTdBsfq30wkUUTQQ0sDCOGT6t8CdOzrEGwPacs8PfeO6eonl2LsOyZk6TEPCJu0W+cFiZUmmZ3SeNuwBsxlZmAx5nAyzyd9mxSXdiFlGK0qBx7XFxwJQBSMDzq2EXjBMYhf7bU2t60rK+PNmbX4gDaH9C/I7Rekx2ecqVqTzyOWEp4FNJ1AXpLc7kBesVIGYUNg2dDap04WcqDFiJXP/TKtgqIGSI5rTv5Z730= Dell@DESKTOP-P8F3BLB"
}

resource "aws_security_group" "bastion-sg" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage-bastion-sg"
  }
}

  resource "aws_instance" "bastion" {
  ami           = "ami-06489866022e12a14"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.bastion-sg.id] 
  subnet_id  = aws_subnet.public[0].id
  associate_public_ip_address =true
  key_name = aws_key_pair.demo.id


  tags = {
    Name = "bastion"
  }
}


