provider "aws" {
  region = "us-east-1"
}

# Crear key pair a partir de tu llave pública local (~/.ssh/id_rsa.pub)
resource "aws_key_pair" "mi_key" {
  key_name   = "mi-llave-ec2"
  public_key = file("ssh_public_key")
}

# Crear VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

# Crear Subred pública dentro de la VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public_subnet"
  }
}

# Crear Internet Gateway para salida a Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_igw"
  }
}

# Crear tabla de rutas pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

# Ruta para salida a internet (0.0.0.0/0)
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Asociar tabla de rutas a la subred pública
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group para permitir HTTP (80) y SSH (22)
resource "aws_security_group" "ubuntu_sg" {
  name        = "permite-web-ssh"
  description = "Permite acceso HTTP (80) y SSH (22)"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia EC2 Ubuntu con Docker y despliegue automático
resource "aws_instance" "servidor_ubuntu" {
  ami                         = "ami-0f9de6e2d2f067fca"  # Ubuntu 22.04 LTS us-east-1 (verifica en AWS)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ubuntu_sg.id]
  associate_public_ip_address = true
  key_name                   = aws_key_pair.mi_key.key_name

  user_data = <<-EOF
                #!/bin/bash
                set -e

                apt-get update
                apt-get install -y git docker.io
                systemctl enable docker
                systemctl start docker || systemctl restart docker

                git clone https://github.com/andres200314/aws-autodeploy-app.git /home/ubuntu/proyecto
                cd /home/ubuntu/proyecto/app
                docker build -t app-2048 .
                docker run -d -p 80:80 app-2048
                EOF

  tags = {
    Name = "Ubuntu-Docker"
  }
}

# Output: IP pública para conexión SSH / HTTP
output "ip_publica" {
  description = "IP pública de la instancia Ubuntu con Docker"
  value       = aws_instance.servidor_ubuntu.public_ip
}
