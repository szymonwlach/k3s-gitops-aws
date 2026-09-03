variable "db_password"{
  type = string
  sensitive = true
}


resource "aws_db_subnet_group" "main" {
  name = "k3s-gitops-db-subnet"
  subnet_ids = [aws_subnet.data_1_pv.id,aws_subnet.data_2_pv.id]
}

resource "aws_security_group" "rds_access" {
  name = "rds-access"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Postgres from k3s server only"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.k3s_server_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres_db" {
  db_name = "incidents"
  engine = "postgres"
  instance_class = "db.t3.micro"
  password = var.db_password
  allocated_storage = 20
  max_allocated_storage = 50
  identifier = "k3s-gitops-db"
  username = "appadmin"
  skip_final_snapshot = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_access.id]
}