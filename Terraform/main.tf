# 1. Look up the default VPC and public subnets in your region
data "aws_vpc" "default" {
  default = true
}

# 2. Look up the latest official Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 3. Security Group: Inbound port 8000, outbound unrestricted
resource "aws_security_group" "app_sg" {
  name        = "cloud-foundation-app-sg"
  description = "Allow inbound HTTP traffic on port 8000"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Application HTTP Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-foundation-sg"
  }
}

# 4. EC2 Instance with User Data Bootstrap
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # AWS Free Tier eligible (or t3.micro)

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Cloud-init script executed on first boot
  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update packages and install Docker
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              # Run the hardened container from GHCR
              docker run -d --restart always -p 8000:8000 --name cloud-app ghcr.io/ibaad12345/cloud-foundation-app:latest
              EOF

  tags = {
    Name = "cloud-foundation-app-server"
  }
}

