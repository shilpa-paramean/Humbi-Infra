# Citadel Eject

Process to eject a client from Citadel

## Set Terraform.backend CloudFormation

On  client's audit or  shared AWS account, run terraform.backend.cf.yml CloudFormation to create the new backend s3 bucket.
```
    1. CitadelAutomation: true
    2. KMSKeyARN: "Check if  backend s3 bucket needs CMK"
    3. NameSuffix: "blank"
    3. OrgName: `<client_name>`
    4. RoleARNs: "blank"
```

## Set client's new repo

```
Clone Citadel infra (https://github.com/DNXCitadel/infra) to client's new repo.
```

## Set Makefile, backend and settings

    1, Copy `Makefile`, `_backend.tf`, and `_settings.tf` to each stack folder (audit, baseline, identity, network, platform, and platform-kubernetes)
    2. Check if configuration is set correctly to run client's infra.
    3. 

## Create workspace folder

    1. Create a folder in each stack called `workspaces` 
    2. Copy yaml files from client-<name>/<stack> repo to each <stack>/workspaces
    3. Copy files under repo client-<name>/<stack>/overwrites/* and /extras to new repo root/<stack>/* overwriting any file. Files under extra should be renamed if the file already exist.

## Test configuration

    Test make google-auth init plan

## Set .github/workflow to new repo

Make sure client can run workflow from new repo on the vendor chosen.

### Remove any stack that is not in use

On each client's AWS account, check CloudFormation "identity-baseline" and include any role arn used by developers, admins and pipeline users.
Update README.md files