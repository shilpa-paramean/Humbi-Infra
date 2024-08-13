{% set audit_account = stacks.audit.workspaces.values() | first %}

# Stacks

This foundation is split into "stacks".
Each stack contains terraform code and modules and deploys independently of others, but they might have resource dependencies between them, so the order of deployment is important.

Each stack has by default the following files:

| File | Description |
| ---- | ----------- | 
| `Makefile` | Used as an entrypoint for commands |
| `.env.template` | This is used to generate the `.env` file. Only variables added here are passed to Terraform when executing |
| `one.yaml` | Contains all variables passed to terraform (as `local.workspace.<var>`), per workspace |
| `_backend.tf` | Sets the backend where Terraform stores its state file (usually S3) |
| `_settings.tf` | Provider and variables used by Terraform |
| `_data.tf` | Where most of the Terraform "Data" resources live |
| `README.md` | Instructions on how to run that stack and its workspaces |
| `*.tf` | All the other terraform files in HCL format |

## Terraform State File

The state file of all stacks are stored at an S3 bucket.

This S3 bucket usually lives in the Shared-Services account, and alternatively in the Master account for architectures where there's no Shared-Services account.

To create the S3 bucket, deploy the CloudFormation file at `./cf-templates/shared-services/terraform-backend.cf.yml` to the Shared-Services (or Master) account.

The parameters for the stack are:

* OrgName - Name of your organization, will determine the name of the bucket as `${OrgName}-terraform-backend`
* RoleARNs - List of comma-separated Roles and/or AWS Account IDs that are allowed to read and write files to the bucket. It's usually the role `arn:aws:iam::<account_id>:role/InfraDeployAccess` of your Shared-Service account.
* KMSKeyARN - Even though the S3 Bucket has encryption turned on, in some occasions it might be required to use a custom KMS key. (Optional)

Once the bucket is created, all stacks have a file `_backend.tf` that looks like:

```hcl
terraform {
  backend "s3" {
    bucket  = "{{audit_account.org_name}}-terraform-backend"
    key     = "platform"
    region  = "ap-southeast-2"
    encrypt = true
    role_arn = "arn:aws:iam::<shared_services_account_id>:role/InfraDeployAccess" # shared-services role
  }
}
```

Make sure the region above matches the region where the S3 bucket is deployed.