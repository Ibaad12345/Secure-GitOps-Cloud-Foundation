data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Redirect stdout and stderr to a dedicated log file as well as syslog
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "=== Starting Cloud-Init Workload Bootstrap ==="

              # Wait for unattended-upgrades background lock to release safely
              while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
                echo "Waiting for other package manager processes to complete..."
                sleep 5
              done

              # Update packages and install Docker
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              # Run container mapped to standard HTTP host port 80
              docker run -d \
                --restart always \
                -p 80:8000 \
                --name cloud-app \
                ghcr.io/ibaad12345/cloud-foundation-app:latest

              echo "=== Cloud-Init Bootstrap Complete ==="
              EOF

  tags = {
    Name = "cloud-foundation-workload-host"
  }
}