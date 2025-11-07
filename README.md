# AWS Multi-Account Architecture

Terraform modules for managing AWS Organizations with multiple accounts, organizational units, Service Control Policies (SCPs), and cross-account IAM roles.

## Features

- **AWS Organizations**: Multi-account management
- **Organizational Units**: Logical grouping of accounts
- **Service Control Policies**: Centralized security policies
- **Cross-Account Access**: Secure IAM roles for account access
- **Account Isolation**: Security and billing isolation

## Architecture

```
Root
├── Security OU
│   ├── Security Account
│   └── Logging Account
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
├── Applications OU
│   ├── Production Account
│   ├── Staging Account
│   └── Development Account
└── Sandbox OU
    └── Sandbox Accounts
```

## Usage

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

## Configuration

Edit `terraform/organizations.tf` to configure accounts:

```hcl
accounts = {
  security = {
    email   = "security@example.com"
    name    = "Security"
    ou_path = "Security"
    tags = {
      Environment = "security"
    }
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Author

**Dmytro Bazeliuk**
- Portfolio: https://devsecops.cv
- GitHub: [@dmytrobazeliuk-devops](https://github.com/dmytrobazeliuk-devops)
