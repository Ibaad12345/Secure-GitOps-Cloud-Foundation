# 1. Reference the existing GitHub Actions OIDC provider in your AWS account
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Create the IAM Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:Ibaad12345/Secure-GitOps-Cloud-Foundation:*",
              "repo:ibaad12345/Secure-GitOps-Cloud-Foundation:*"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "github-actions-terraform-role"
  }
}

# 3. Attach Administrator privileges so the workflow can manage infrastructure
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 4. Output the Role ARN
output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions via OIDC"
  value       = aws_iam_role.github_actions_role.arn
}