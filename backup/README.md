# Platform Terraform Stack

This stack manages the creation of AWS Backup.

## Configuration Variables

All configuration is loaded from the file `<client_name>-<environment>-<region>-default` by the file `_settings.tf`.

Variables can change per workspace, to access a variable in your .tf file, set at `<client_name>-<environment>-<region>-default` under all workspaces and use: `local.workspace.my_variable`

Variables that are common to all workspaces can be set at `_settings.tf`.

## Resources

- AWS Backup Vault
- AWS Backup Vault Lock
- AWS Backup Vault Notification
- AWS Backup Plan
- IAM Roles

## Workspaces

- `<client_name>-<environment>-<region>-default`

## Deploying

### 1. Export Workspace

1. backup-center: `export WORKSPACE=bubbletea4-backup-ap-southeast-2-default`
3. prod:          `export WORKSPACE=bubbletea4-prod-ap-southeast-2-default`

### 2. Google/Azure SSO Authentication
```
Export your temporary AWS credentials.

export AWS_ACCESS_KEY_ID=YourSecretKeyId
export AWS_SECRET_ACCESS_KEY=YourSecretAccessKey
export AWS_SESSION_TOKEN=YourSessionToken

```

### 3. Export aditional variables 
```
export AWS_ROLE=yourDNXAccessRole
export AWS_ACCOUNT_ID="AWSAccountId"
```

### 4. terraform init
```
make init
```

### 5. terraform plan
```
make plan
```

### 6. terraform apply
```
make apply
```

### Other operations supported
Enter a shell with AWS credentials and terraform:
```
make shell

# common commands to run inside the shell:

# check your AWS creds by running:
aws sts get-caller-identity

# list terraform state with:
terraform state list

# import a terraform resource:
terraform import aws_guardduty_detector.member[0] 00b00fd5aecc0ab60a708659477e0627
```

### Working with external modules locally (i.e. DNX Labs terraform modules)
Export `EXTERNAL_MODULES` variable with the path to your modules.
```
export EXTERNAL_MODULES=/path/to/your/local/modules

``` 

Change the module's source.
```
module "my-external-module" {
    source = "/modules/terraform-my-external-module"

    ...
}
````