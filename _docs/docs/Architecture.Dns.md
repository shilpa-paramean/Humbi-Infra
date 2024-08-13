# DNS

The AWS Foundation stack has multiple AWS Accounts and each one has a Route53 Hosted zone, each environment (shared-service, non production and production) will have a valid DNS (Domain Name Service) entry and a valid SSL certificated managed by ACM (AWS Certificate Manager).

The stack controlling the network resources is the **Platform** stack.

The hosted zones per account are:

| Account | Domain | Name Servers |
| ------- | ------ | ------------ |
{%- for workspace_name, workspace in outputs.network.items() %}
{%- for domain_name, domain in workspace.domain.items() %}
| {{ stacks.network.workspaces[workspace_name].network.name }} | {{ domain_name }} | {{ domain.name_servers |join(', ') }} |
{%- endfor %}
{%- endfor %}

In a standard DNS setup, the domains are hosted in the Production account, and a subdomain is deployed per AWS Workload Account.

As an example, if your domain name is mycompany.com, the setup would look like:

Production account hosted zones:

- mycompany.com
- cloud.mycompany.com
- prod.cloud.mycompany.com

While the other accounts (example: staging and dev)

- staging.cloud.mycompany.com
- dev.cloud.mycompany.com

The chain of DNS delegation look like:

| Hosted Zone Name | Record | Record Type | Values |
| ---------------- | ------ | ----------- | ------ |
| mycompany.com | cloud.mycompany.com | NS | (NS of cloud.mycompany.com) |
| cloud.mycompany.com | staging.cloud.mycompany.com | NS | (NSs of staging.cloud.mycompany.com) |
| cloud.mycompany.com | dev.cloud.mycompany.com | NS | (NSs of dev.cloud.mycompany.com) |

Therefore, nonprod accounts have the public DNS authority controled by the Production account.

So applications in nonprod would use the records:

* myapp.staging.cloud.mycompany.com
* myapp.dev.cloud.mycompany.com

While in production:

* myapp.prod.cloud.mycompany.com (before cutover)
* myapp.mycompany.com or mycompany.com (after cutover)


<!-- ![AWS DNS HLD](images/hld_aws_dns.png) -->