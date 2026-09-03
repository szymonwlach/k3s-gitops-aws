data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = "main"
    Environment = "dev"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "public_1"
    Environment = "dev"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "data_1_pv" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
    tags = {
    Name = "data_1_pv"
    Environment = "dev"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "data_2_pv" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
    tags = {
    Name = "data_2_pv"
    Environment = "dev"
    ManagedBy = "terraform"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main_igw"}
}


resource "aws_route_table" "main_rt_public" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

    tags = { Name = "main_rt"}
}

resource "aws_route_table_association" "main_rt_assoc_public" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.main_rt_public.id

}

resource "aws_security_group" "k3s_server_sg" {
  name        = "k3s-server-sg"
  description = "Security group for k3s EC2 instance"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "allow only my IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}
