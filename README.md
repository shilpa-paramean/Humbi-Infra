Citadel
=======

Folder Structure
----------------
There's a structure you need to follow:

```
./infra                                # clone infra.git here
./infra/.clients                       # create this folder
./infra/.clients/client-<client_name>  # clone client-<client_name>.git here
```

Running Terraform
-----------------

Enter the stack folder desired
```
cd infra/platform
```

Disable the assume role target:
```
export ASSUME_REQUIRED=
```

Set the workspace.

The workspace name is always the name of the YAML file with the configuration inside the client repo and stack folder, example: `client-bubbletea/platform/bubbletea-dev-us-east-1-default.yaml`, the workspace is `bubbletea-dev-us-east-1-default`.
```
export WORKSPACE=<client_name>-dev-us-east-1-default
```


Run terraform init and plan:
```
make init plan
```

How it works?
-------------

The Makefile target called `init` will call another target called `copy_client`, which does:
- Copies all files under `client-<client>/<stack>/extras/*.tf` into `infra/<stack>/extras-*.tf` - use this to add extra Terraform to the stack.
- Copies all files under `client-<client>/<stack>/overwrites/*` into `infra/<stack>/*` - use this to overwrite existing TF files from the stack or to add modules.
- Copies all `client-<client>/<stack>/*.yaml` into `infra/<stack>/.workspaces/*.yaml` - this is where Terraform is going to look for the YAML configuration.

When Terraform runs, `_settings.tf` has a local variable called `workspace`, which loads its data from the workspace-named YAML file, see:
```
locals {
  workspace  = yamldecode(file("./.workspaces/${terraform.workspace}.yaml"))
}
```

Roles
-----

Terraform provider is configured to assume a role called `InfraDeployAccess`

This role is created by the `identity-baseline.cf.yml` stack that you can find in the `_cf-templates` folder.

When Terraform runs from Citadel infrastructure, it uses a `InfraDeploy` role that lives in a secure central account. The ARN is `arn:aws:iam::953027019050:role/InfraDeploy`. From this role, terraform will assume `InfraDeployAccess` on each target account, based on the AWS account ID set in the workspace YAML file.

When running locally, your local role needs to be able to assume `InfraDeployAccess`. 

A common setup is to create a `InfraDeploy` or `AdministratorAccess` role in your shared-services account and assign to your users.

Then add this role ARN as a Trust to the `InfraDeployAccess` in all accounts. This can be done by setting the parameter `TrustARNs` when deploying `identity-baseline.cf.yml`.