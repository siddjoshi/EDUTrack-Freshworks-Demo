# EDUTrack Infrastructure - Terraform

This directory contains Terraform configurations for deploying the EDUTrack AI Learning Platform infrastructure on Microsoft Azure.

## Architecture Overview

The infrastructure deploys the following Azure resources:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Azure Resource Group                                  │
│                     (rg-edutrack-{env}-{region})                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Virtual Network (VNet)                            │    │
│  │                                                                      │    │
│  │  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐     │    │
│  │  │   Web App Subnet │ │ Database Subnet  │ │ Private Endpoint │     │    │
│  │  │   (Delegated)    │ │   (Delegated)    │ │     Subnet       │     │    │
│  │  └────────┬─────────┘ └────────┬─────────┘ └────────┬─────────┘     │    │
│  │           │                    │                    │               │    │
│  └───────────┼────────────────────┼────────────────────┼───────────────┘    │
│              │                    │                    │                    │
│  ┌───────────▼─────────┐ ┌───────▼──────────┐ ┌───────▼──────────┐          │
│  │    App Service      │ │    PostgreSQL    │ │   Key Vault      │          │
│  │  ┌───────────────┐  │ │  Flexible Server │ │ (Secrets Mgmt)   │          │
│  │  │   Frontend    │  │ │                  │ │                  │          │
│  │  │   (React)     │  │ │                  │ └──────────────────┘          │
│  │  └───────────────┘  │ │                  │                               │
│  │  ┌───────────────┐  │ │                  │ ┌──────────────────┐          │
│  │  │   Backend     │  │ │                  │ │  Storage Account │          │
│  │  │   (Python)    │  │ │                  │ │  (Blob Storage)  │          │
│  │  └───────────────┘  │ │                  │ │                  │          │
│  └─────────────────────┘ └──────────────────┘ └──────────────────┘          │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                       Monitoring & Logging                           │    │
│  │  ┌───────────────────┐  ┌───────────────────────┐                   │    │
│  │  │ Application       │  │ Log Analytics         │                   │    │
│  │  │ Insights          │  │ Workspace             │                   │    │
│  │  └───────────────────┘  └───────────────────────┘                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Tools

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50.0
- Azure subscription with appropriate permissions

### Azure Permissions

The deploying user/service principal needs the following permissions:
- Contributor role on the subscription or resource group
- User Access Administrator (for RBAC assignments)
- Key Vault Administrator (for secrets management)

## Directory Structure

```
infrastructure/terraform/
├── main.tf                     # Main configuration with all resources
├── variables.tf                # Variable definitions
├── outputs.tf                  # Output definitions
├── environments/               # Environment-specific configurations
│   ├── dev.tfvars              # Development environment
│   ├── staging.tfvars          # Staging environment
│   └── prod.tfvars             # Production environment
├── modules/                    # Reusable modules
│   ├── webapp/                 # Azure App Service module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── postgresql/             # PostgreSQL Flexible Server module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/                # Storage Account module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── keyvault/               # Key Vault module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/             # Application Insights & Log Analytics module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md                   # This file
```

## Quick Start

### 1. Authenticate with Azure

```bash
# Login to Azure
az login

# Set the subscription
az account set --subscription "<subscription-id>"
```

### 2. Initialize Terraform

```bash
cd infrastructure/terraform
terraform init
```

### 3. Set Required Variables

Set the PostgreSQL admin password (required):

```bash
export TF_VAR_postgresql_admin_password="YourSecurePassword123!"
```

### 4. Deploy to Development

```bash
# Plan the deployment
terraform plan -var-file="environments/dev.tfvars"

# Apply the deployment
terraform apply -var-file="environments/dev.tfvars"
```

### 5. Deploy to Staging

```bash
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

### 6. Deploy to Production

```bash
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

## Environment Configurations

### Development (`dev.tfvars`)

| Resource | SKU/Tier | Notes |
|----------|----------|-------|
| App Service Plan | Standard S1 | 1 instance, basic tier |
| PostgreSQL | B_Standard_B1ms | Burstable, 32 GB storage |
| Storage | Standard LRS | Locally redundant |
| Key Vault | Standard | Non-HSM backed |
| Log Analytics | 90 days retention | |

**Estimated Monthly Cost:** ~$150

### Staging (`staging.tfvars`)

| Resource | SKU/Tier | Notes |
|----------|----------|-------|
| App Service Plan | Premium P1v3 | 3-10 instances, auto-scale |
| PostgreSQL | GP_Standard_D2s_v3 | General Purpose, 64 GB storage |
| Storage | Standard LRS | Locally redundant |
| Key Vault | Standard | Non-HSM backed |
| Log Analytics | 90 days retention | |

**Estimated Monthly Cost:** ~$1,200

### Production (`prod.tfvars`)

| Resource | SKU/Tier | Notes |
|----------|----------|-------|
| App Service Plan | Premium P2v3 | 5-20 instances, auto-scale |
| PostgreSQL | GP_Standard_D4s_v3 | General Purpose, 128 GB storage, HA |
| Storage | Standard GRS | Geo-redundant |
| Key Vault | Premium | HSM-backed |
| Log Analytics | 730 days retention | 2 years for compliance |

**Estimated Monthly Cost:** ~$3,500

## Resources Created

### Core Resources

| Resource | Name Pattern | Description |
|----------|--------------|-------------|
| Resource Group | `rg-edutrack-{env}-{region}` | Container for all resources |
| Virtual Network | `vnet-edutrack-{env}-{region}` | Network isolation |
| App Service Plan | `plan-edutrack-{env}-{region}` | Hosting plan for web apps |
| Frontend Web App | `app-edutrack-web-{env}-{region}` | React frontend |
| Backend Web App | `app-edutrack-api-{env}-{region}` | Python FastAPI backend |
| PostgreSQL Server | `psql-edutrack-{env}-{region}-{suffix}` | Database server |
| Storage Account | `stedutrack{env}{suffix}` | Blob storage for documents |
| Key Vault | `kv-edutrack-{env}-{suffix}` | Secrets management |
| Application Insights | `appi-edutrack-{env}-{region}` | Application monitoring |
| Log Analytics | `log-edutrack-{env}-{region}` | Centralized logging |

### Security Features

- **Network Isolation**: VNet with dedicated subnets for web apps and databases
- **Private Endpoints**: PostgreSQL accessible only via private network (prod)
- **TLS 1.2+**: Enforced on all services
- **Managed Identity**: Web apps use system-assigned managed identity
- **Key Vault Integration**: All secrets stored in Key Vault

### Monitoring & Alerts

- Application performance monitoring
- Response time alerts (>2s for prod, >3s for others)
- Failure rate alerts
- Exception monitoring
- Availability tests (production only)

## Remote State Configuration

For production use, configure remote state storage:

1. Create a storage account for Terraform state:

```bash
# Create resource group
az group create --name tfstate-rg --location eastus

# Create storage account
az storage account create \
  --name tfstateedutrack \
  --resource-group tfstate-rg \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name tfstateedutrack
```

2. Uncomment the backend configuration in `main.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstateedutrack"
  container_name       = "tfstate"
  key                  = "edutrack.terraform.tfstate"
}
```

3. Re-initialize Terraform:

```bash
terraform init -migrate-state
```

## CI/CD Integration

### GitHub Actions

Example workflow for automated deployment:

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
    paths:
      - 'infrastructure/terraform/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Terraform Init
        working-directory: infrastructure/terraform
        run: terraform init
      
      - name: Terraform Plan
        working-directory: infrastructure/terraform
        run: terraform plan -var-file="environments/dev.tfvars" -out=tfplan
        env:
          TF_VAR_postgresql_admin_password: ${{ secrets.POSTGRESQL_PASSWORD }}
      
      - name: Terraform Apply
        working-directory: infrastructure/terraform
        run: terraform apply -auto-approve tfplan
```

## Outputs

After deployment, the following outputs are available:

| Output | Description |
|--------|-------------|
| `frontend_webapp_url` | URL of the frontend application |
| `backend_webapp_url` | URL of the backend API |
| `postgresql_server_fqdn` | FQDN of the PostgreSQL server |
| `storage_account_name` | Name of the storage account |
| `key_vault_uri` | URI of the Key Vault |
| `application_insights_instrumentation_key` | App Insights instrumentation key |

View outputs after deployment:

```bash
terraform output
```

## Troubleshooting

### Common Issues

1. **PostgreSQL deployment fails**: Ensure the subnet delegation is properly configured
2. **Key Vault access denied**: Verify the deploying user has Key Vault Administrator role
3. **Web app VNet integration fails**: Check subnet delegation for `Microsoft.Web/serverFarms`

### Logs

View deployment logs in Azure Portal:
- Activity Log in Resource Group
- Deployment blade in Resource Group

## Security Considerations

- Never commit `*.tfvars` files containing secrets
- Use environment variables or Azure Key Vault for sensitive values
- Enable soft delete and purge protection for Key Vault in production
- Use private endpoints for database access in production
- Regularly rotate secrets and access keys

## NFR Traceability

| NFR ID | Requirement | Implementation |
|--------|-------------|----------------|
| SEC-DATA-001 | Encryption at rest | Azure Storage encryption enabled |
| SEC-DATA-002 | TLS 1.2+ | Minimum TLS version set to 1.2 |
| SEC-APP-005 | Key Vault for secrets | All secrets stored in Key Vault |
| PERF-RES-001 | App Service scaling | Auto-scale configured for production |
| AVAIL-001 | 99.9% uptime | Zone-redundant deployment in production |
| OBS-LOG-001 | Centralized logging | Log Analytics workspace configured |

## Support

For issues with infrastructure:
1. Check the Azure Portal for resource health
2. Review Terraform state with `terraform show`
3. Contact the DevOps team at devops@edutrack.example.com
