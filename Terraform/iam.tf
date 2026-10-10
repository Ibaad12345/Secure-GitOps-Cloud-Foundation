# 1. Trust policy allowing the EC2 service principal to assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. IAM Role for the workload compute instance
resource "aws_iam_role" "app_instance_role" {
  name               = "cloud-foundation-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "cloud-foundation-ec2-ssm-role"
  }
}

# 3. Attach AWS Managed Policy for SSM Session Manager core capabilities
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Instance Profile wrapper to deliver temporary STS credentials to EC2
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "cloud-foundation-ec2-instance-profile"
  role = aws_iam_role.app_instance_role.name

  tags = {
    Name = "cloud-foundation-ec2-instance-profile"
  }
}