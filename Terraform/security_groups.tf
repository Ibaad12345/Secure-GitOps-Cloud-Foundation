resource "aws_security_group" "web_sg" {
  name        = "cloud-foundation-web-sg"
  description = "Allow inbound HTTP on standard port 80; full egress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP Ingress"
    from_port   = 80
    to_port     = 80
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
    Name = "cloud-foundation-web-sg"
  }
}