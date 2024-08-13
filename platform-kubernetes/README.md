# Kubernetes Terraform Stack

This stack manages controllers and operators deployed inside EKS cluster.

This stack requires the EKS cluster from platform stack.

## Configuration Variables

All configuration is loaded from the file `one.yaml` by the file `_settings.tf`.

Variables can change per workspace, to access a variable in your .tf file, set at `one.yaml` under all workspaces and use: `local.workspace.my_variable`

Variables that are common to all workspaces can be set at `_settings.tf`.

## Resources

- IAM Roles

## Workspaces

- nonprod-ap-southeast-2-dev
- prod-ap-southeast-2-default

## Deploying

### 1. Export Workspace

1. nonprod:         `export WORKSPACE=nonprod-ap-southeast-2-dev`
2. prod:            `export WORKSPACE=prod-ap-southeast-2-default`


### 2. Google/Azure SSO Authentication
```
make google-auth
# or
make azure-auth
```

### 3. terraform init
```
make init
```

### 4. terraform plan
```
make plan
```

### 5. terraform apply
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
terraform import aws_guardduty_detector.member[0] 00b00fd5aecc0ab60a708659477e9617
```

## Operations

### kube-shell

Set the variables according to the cluster you want to connect (check one.yaml for the name and ID):

```bash
export CLUSTER_NAME=dev-apps
export AWS_ACCOUNT_ID=313644200121
export AWS_ROLE=bubbletea3DNXAccess
```

Open kube-shell with:
```bash
make kube-shell

# test connectivity:
kubectl get nodes
```

### argocd

Set the variables as shown in the kube-shell section above.

Get the initial password:
```bash
make kube-shell
echo `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
```

Creating the tunnel:
```bash
make argocd-tunnel
```

### kubernetes-dashboard

Set the variables as shown in the kube-shell section above.

```bash
make kube-shell
# get the token with:
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | awk '/^kubernetes-dashboard-token-/{print $1}') | awk '$1=="token:"{print $2}'
# exit the shell
exit
# create the tunnel
make dashboard-tunnel
```