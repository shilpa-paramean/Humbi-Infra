# Terraform

Terraform is used as the main infrastructure-as-code of this foundation.

## The 3-musketeers Pattern: Makefiles and Docker

Terraform runs from a Docker container using Makefile as the entrypoint for the commands.

This approach is inspired by 3-musketeers (https://3musketeers.io/) and provides a few benefits:

* The version of Terraform (and other tools) are defined in the Makefile as a docker tag for the Terraform image. This allows it to run with same version regardless from where it's running from.
* Portability: Allows different hosts to run the stack without having all the tools installed, except for Docker and Make.
* Simpler commands: instead of `terraform init; terraform workspace select my-workspace; terraform plan -out=my-plan`, you can just run `make init plan`.
* Dependency handling: The Makefile can already manage dependency between commands, example: Assume a role automatically before pushing a docker image to ECR.

## .env.template File

This file is used by the Makefile to generate the `.env` file which in turn is used in the container running Terraform (or other tools like the AWS CLI).

There are no values defined in this file, only environment variable names. This means if the variable is defined in the shell running the Makefile, it will pass the value to inside the container. Without the variable declared in this file, the container will not be able to access its value.

One example is the variable `TF_LOG` that can be used to debug Terraform. You can set this variable in your terminal:
```
export TF_LOG=debug
```
Then run terraform via the Makefile:
```
make plan
```
And Terraform will run in debug mode.

## Workspaces

Terraform Workspaces is a feature that allows it to run the same Terraform code targeting different environments.

More info at https://www.terraform.io/docs/language/state/workspaces.html

Workspaces are defined under the `workspaces:` key in the `one.yaml` file inside each stack.

Parameters for that stack will change depending on the workspace selected.

Example:

main.tf:
```hcl
locals {
  env       = yamldecode(file("./one.yaml"))
  workspace = local.env["workspaces"][terraform.workspace]
}

output "environment_name" {
  value = local.workspace.environment_name
}
```

one.yaml:
```yaml
workspaces:
  production:
    environment_name: Prod
  development:
    environment_name: Dev
```

The example above will print different a `environment_name` depending on the workspace selected:
```bash
WORKSPACE=production make init plan
# prints output: environment_name=Prod

WORKSPACE=development make init plan
# prints output: environment_name=Dev
```

## Workspace Naming

The naming standard used in this foundation for Terraform Workspace is:

`<account>-<region>-<environment>`

If there is only one environment (per account), use `default` as environment name.

If the stack span across multiple accounts, use `all` as the account name.

For workspaces that are not region specific or span across multiple regions, use `global` as region.

Examples:

|                 | Account Name | Region Name      | Environment Name |
| --------------- | ------------ | ---------------- | ---------------- |
| specific        | `nonprod`    | `us-west-2`      | `qa`             |
| only one env    | `management` | `ap-southeast-2` | `default`        |
| across regions  | `prod`       | `global`         | `green`          |
| across accounts | `all`        | `us-east-2`      | `default`        |
| across both     | `all`        | `global`         | `default`        |

Even if you plan to deploy the stack only one time (one environment), still a good idea to use workspaces. Reason is if in the future another environment is required making workspaces necessary, it's not possible to migrate your deployed stack to a workspace easily.