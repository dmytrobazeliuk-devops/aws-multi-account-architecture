# Cross-Account IAM Roles
# Enables secure access between AWS accounts

variable "trusted_account_ids" {
  description = "List of trusted AWS account IDs"
  type        = list(string)
  default     = []
}

variable "role_name" {
  description = "Name of the cross-account role"
  type        = string
  default     = "CrossAccountAccess"
}

# Cross-account role for read-only access
resource "aws_iam_role" "cross_account_readonly" {
  name = "${var.role_name}-ReadOnly"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in var.trusted_account_ids :
            "arn:aws:iam::${account_id}:root"
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "devsecops-cross-account"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "${var.role_name}-ReadOnly"
    ManagedBy = "Terraform"
  }
}

# Attach read-only policy
resource "aws_iam_role_policy_attachment" "cross_account_readonly" {
  role       = aws_iam_role.cross_account_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Cross-account role for admin access (use with caution)
resource "aws_iam_role" "cross_account_admin" {
  name = "${var.role_name}-Admin"
  count = var.enable_admin_access ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in var.trusted_account_ids :
            "arn:aws:iam::${account_id}:root"
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "devsecops-cross-account-admin"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "${var.role_name}-Admin"
    ManagedBy = "Terraform"
  }
}

variable "enable_admin_access" {
  description = "Enable admin cross-account access"
  type        = bool
  default     = false
}

resource "aws_iam_role_policy_attachment" "cross_account_admin" {
  count      = var.enable_admin_access ? 1 : 0
  role       = aws_iam_role.cross_account_admin[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Outputs
output "cross_account_readonly_role_arn" {
  description = "ARN of the cross-account read-only role"
  value       = aws_iam_role.cross_account_readonly.arn
}

output "cross_account_admin_role_arn" {
  description = "ARN of the cross-account admin role"
  value       = var.enable_admin_access ? aws_iam_role.cross_account_admin[0].arn : null
}

