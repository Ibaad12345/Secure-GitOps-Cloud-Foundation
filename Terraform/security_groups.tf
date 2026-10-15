# Tier 1: ALB Security Group (Public Edge)
resource "aws_security_group" "alb_sg" {
  name        = "cloud-foundation-alb-sg"
  description = "Accept public HTTP traffic on port 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress forwards traffic to the backend instances
  egress {
    description = "Allow all outbound traffic to targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-foundation-alb-sg"
  }
}

# Tier 2: EC2 Instance Security Group (Chained to ALB)
resource "aws_security_group" "instance_sg" {
  name        = "cloud-foundation-instance-sg"
  description = "Allow inbound container traffic ONLY from ALB security group"
  vpc_id      = aws_vpc.main.id

  # Ingress ONLY from the ALB's security group ID
  ingress {
    description     = "App container port from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Egress for Docker pulls, SSM communication, and OS updates
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-foundation-instance-sg"
  }
}