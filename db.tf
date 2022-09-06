resource "aws_security_group" "db-sg" {
  name        = "db"
  description = "allow db"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "bastion"
    from_port        = 3369
    to_port          = 3369
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion-sg.id]
  }
  ingress {
    description      = "application"
    from_port        = 3369
    to_port          = 3369
    protocol         = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage-db-sg"
  }
}




resource "aws_db_subnet_group" "db-subnet" {
  name       = "stage-db-subnetgroup"
  subnet_ids = [for subnet in aws_subnet.data : subnet.id]

  tags = {
    Name = " db subnet group"
  }
}

resource "aws_db_instance" "stage" {
  allocated_storage    = 30
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "naveen"
  password             = "global12345"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.db-subnet.id
  skip_final_snapshot  = true
  publicly_accessible = false
  backup_retention_period = 7
  multi_az = true

  tags = {
    Name = "stage-db"
  }
}
