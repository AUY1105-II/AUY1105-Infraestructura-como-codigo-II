resource "aws_key_pair" "mi_key" {
  key_name   = "vockey"
  public_key = ""
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Permitir acceso SSH desde una IP especifica"
  vpc_id      = aws_vpc.mi_vpc.id

  ingress {
    description = "SSH desde IP especifica"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.100/32"] # Acceso solo desde esta IP
  }

  egress {
    description = "Permitir trafico de salida a cualquier lugar"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-access"
  }
}

resource "aws_instance" "mi_ec2" {
  ami                         = "ami-012967cc5a8c9f891"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.mi_key.key_name
  subnet_id                   = aws_subnet.subnet_publica_1.id
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  tags = {
    Name = "MiInstancia"
  }
}