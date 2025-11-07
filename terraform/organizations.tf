# AWS Organizations Configuration
# Multi-account architecture with organizational units

variable "organization_name" {
  description = "Name of the AWS Organization"
  type        = string
  default     = "devsecops-org"
}

variable "accounts" {
  description = "Map of account configurations"
  type = map(object({
    email     = string
    name      = string
    ou_path   = string
    tags      = map(string)
  }))
  default = {}
}

# AWS Organization
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "sso.amazonaws.com",
  ]

  feature_set = "ALL"
}

# Organizational Units
resource "aws_organizations_organizational_unit" "main" {
  for_each = toset([
    "Security",
    "Infrastructure",
    "Applications",
    "Sandbox"
  ])

  name      = each.value
  parent_id = aws_organizations_organization.main.roots[0].id
}

# AWS Accounts
resource "aws_organizations_account" "main" {
  for_each = var.accounts

  name                       = each.value.name
  email                      = each.value.email
  iam_user_access_to_billing = "DENY"
  parent_id                  = aws_organizations_organizational_unit.main[each.value.ou_path].id

  tags = merge(
    each.value.tags,
    {
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    ignore_changes = [role_name]
  }
}

# SCPs (Service Control Policies)
resource "aws_organizations_policy" "deny_root" {
  name        = "DenyRootUser"
  description = "Deny root user access"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_root" {
  policy_id = aws_organizations_policy.deny_root.id
  target_id = aws_organizations_organization.main.roots[0].id
}

# Outputs
output "organization_id" {
  description = "ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "root_id" {
  description = "ID of the root organizational unit"
  value       = aws_organizations_organization.main.roots[0].id
}

output "account_ids" {
  description = "Map of account names to account IDs"
  value = {
    for k, v in aws_organizations_account.main : k => v.id
  }
}

