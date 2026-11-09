# Oracle Autonomous Database Serverless on Azure with Terraform from Windows

Provision a private Oracle **19c** Autonomous Database Serverless lab from a
Windows laptop. Terraform runs locally; no GitHub Actions or hosted runner is used.

## Resources

Terraform creates a resource group, a virtual network, an Oracle-delegated subnet,
and one database with **2 ECPUs, 20 GB, License Included, mTLS, and compute/storage
autoscaling disabled**. The subnet delegation is `Oracle.Database/networkAttachments`.

AzureRM manages the networking; AzAPI manages the database using the stable
`2025-09-01` API. The installed AzureRM 4.81.0 database schema requires storage in
TB; AzAPI lets us explicitly request 20 GB through `dataStorageSizeInGbs`.

No VM, VPN gateway, NAT gateway, public database ACL, standby, or optional backup
job is created. Service-managed automatic backups are not disabled: retention is
set to one day, as allowed by Oracle's current Azure provisioning guide.

## Prerequisites

1. An eligible active Azure subscription, Oracle Database@Azure Marketplace
   purchase, and Oracle Cloud account showing **Activated**.
2. Appropriate Azure billing, subscription and OCI permissions for onboarding
   and resource creation. The CLI identity must have access to the target group.
3. Providers registered: `Oracle.Database`, `Microsoft.BareMetal`,
   `Microsoft.Network`, and `Microsoft.Compute`.
4. Before creating the delegated subnet, register
   `EnableRotterdamSdnApplianceForOracle` under **both** `Microsoft.Baremetal`
   and `Microsoft.Network`. Portal path: Subscriptions > your subscription >
   Settings > Preview features. Search the feature, select both rows, Register,
   confirm, and wait until both show **Registered** (can take up to 60 minutes).
   Confirm advanced networking and ADB-S availability for your selected region.
5. Terraform >=1.16.6,<2, Azure CLI, PowerShell, and non-overlapping private ranges.

Lab workstation versions: Terraform 1.16.6, Azure CLI 2.92.0. Provider lock file
records AzureRM 4.81.0 and AzAPI 2.13.0. Keep it for reproducibility.

References:
- [Oracle prerequisites](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/oaaprerequisites.htm)
- [Microsoft network planning](https://learn.microsoft.com/en-us/azure/oracle/oracle-db/oracle-database-network-plan)
- [Oracle delegated subnet](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/azucr-create-delegated-subnet.html)
- [Oracle Serverless provisioning](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/azucr-create-autonomous-ai-database-serverless.html)

## Run from Windows PowerShell

Clone this repository, open the folder in VS Code, and run commands from that
folder. Sign in using the URL/code in Chrome and complete MFA yourself:

```powershell
az login --use-device-code
az account set --subscription "YOUR_AZURE_SUBSCRIPTION_ID"
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`: replace the subscription placeholder and choose approved
ranges, region and names. Example IPs in this repository differ from the original
private lab. Region listings are not a guarantee of service capacity. Check the
available database versions before changing `database_version`.

```powershell
terraform init
terraform validate
```

Load a **new database ADMIN password** privately in the same PowerShell window:

```powershell
$databasePasswordInput = Read-Host 'Enter database ADMIN password' -AsSecureString
$env:TF_VAR_admin_password = [System.Net.NetworkCredential]::new('', $databasePasswordInput).Password
$databasePasswordInput.Dispose()
Remove-Variable databasePasswordInput
terraform plan '-out=database.tfplan'
```

Use 12-30 characters with uppercase, lowercase and a digit; exclude double quotes
and ADMIN. Keep the password privately for SQL Developer. It is a sensitive,
ephemeral Terraform input passed through AzAPI's write-only `sensitive_body`,
so it is excluded from saved plans and state. It remains in this process's
environment until removed or the window closes. Do not print it.

**Review the plan before applying.** From an empty deployment this cumulative
configuration should create **four resources**. It does not run files one at a
time. In the original tutorial, files were added between plans to demonstrate
resource group, VNet, subnet, and database creation separately. If those resources
already exist, use their original Terraform state; do not apply a fresh clone
against the same names or copy a different deployment's state.

After review, in the same password-loaded window:

```powershell
terraform apply 'database.tfplan'
```

Run the saved plan **once**. Wait for completion; do not interrupt or repeat it.
After success:

```powershell
Remove-Item Env:TF_VAR_admin_password
terraform output
```

For another change, enter the password again and generate a new plan. A saved
plan can become stale after state changes. Keep local state private and backed
up; do not commit state, plans, wallets, credentials, or local tfvars.

## Understand the files

| File | Purpose |
| --- | --- |
| versions.tf | Provider requirements and Azure CLI-backed subscription configuration |
| variables.tf | Inputs, defaults and validation |
| terraform.tfvars.example | Copyable example inputs without real account identifiers |
| main.tf | Resource group |
| network.tf | VNet linked to the resource group |
| subnet.tf | Subnet linked to the VNet with Oracle service delegation |
| database.tf | Private 19c database linked to the existing subnet |
| outputs.tf | Non-secret deployment results |
| Set-DatabasePassword.ps1 | Optional hidden-input helper, equivalent to interactive commands above |
| .terraform.lock.hcl | Selected provider versions and integrity hashes |

Terraform combines all `.tf` files in a folder. References define dependencies;
filenames organize code for readers. State records which Azure resources belong
to this deployment, allowing unchanged resources to be retained on later runs.

## Connection and costs

The database is private. A desktop connection needs a separately designed private
network path/tunnel and DNS, plus its mTLS wallet and database credentials. This
repository does not create that access path. Peering is relevant for a client in
another VNet; it is not needed just to reach another subnet in the same VNet.

Creating the database starts billable usage. Stopping compute does not remove
storage/backup charges. This configuration does not automatically stop the
database or set a spending cap. Review current rates and clean up intentionally;
`terraform destroy` deletes the database and managed networking, so preserve any
data you need first. Do not run it while creation is in progress.

## Verification status

The original lab created the resource group, VNet, delegated subnet and database.
The database apply completed in 25 minutes and 12 seconds, with one resource
added and no changes or deletions. A subsequent read-only Azure API check on
November 9, 2026 confirmed **Succeeded / Available**, Oracle **19c**, **2 ECPUs**
and **20 GB** of allocated storage. SQL connectivity has not yet been verified.
