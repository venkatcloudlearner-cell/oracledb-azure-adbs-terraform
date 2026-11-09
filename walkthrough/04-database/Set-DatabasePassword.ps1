# Run in the same PowerShell window used for Terraform plan and apply.
# This script never saves or displays the password.
$databasePasswordInput = Read-Host 'Enter a new password for database ADMIN (12-30 characters)' -AsSecureString
try {
    $env:TF_VAR_admin_password = [System.Net.NetworkCredential]::new('', $databasePasswordInput).Password
    Write-Host 'ADMIN password loaded for Terraform in this PowerShell window only.'
} finally {
    $databasePasswordInput.Dispose()
    Remove-Variable databasePasswordInput
}
