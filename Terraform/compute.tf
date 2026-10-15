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

  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.app_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "=== Starting Cloud-Init Workload Bootstrap ==="

              while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
                echo "Waiting for other package manager processes to complete..."
                sleep 5
              done

              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              # ALB forwards directly to container target port 8000
              docker run -d \
                --restart always \
                -p 8000:8000 \
                --name cloud-app \
                ghcr.io/ibaad12345/cloud-foundation-app:latest

              echo "=== Cloud-Init Bootstrap Complete ==="
              EOF

  tags = {
    Name = "cloud-foundation-workload-host"
  }
}