data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name = "k3s-deployer"
  public_key = file("C:/Users/szymw/.ssh/id_ed25519.pub")
}

resource "aws_instance" "k3s_server" {
  instance_type = "t3.small"
  ami = data.aws_ami.ubuntu.id
  subnet_id = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.k3s_server_sg.id]
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash
curl -sfL https://get.k3s.io | sh -
   EOF
  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "k3s_server"
  }
  
}

output "k3s_server_public_ip" {
  value = aws_instance.k3s_server.public_ip
}