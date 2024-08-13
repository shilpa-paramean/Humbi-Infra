# ACM Certificates

ACM is a service provided by AWS that automatically manages SSL/TLS certificates.

Advantages of using ACM instead of managing own certificates are:

* The private certificate is never exposed or available for download
* It's free
* Automatically renews (only when in use, attached to an ALB, Cloudfront or API Gateway for instance)

And comes with some disadvantages:

* The private certificate is never available for download - this can be a disadvantage depending on the use case
* Can only be used with AWS services like ALB, Cloudfront and API Gateway
* Does not provide some features like Organizational Validation (OV) or Extended Validation (EV)

ACM can also be used to store certificates purchased elsewhere. You can easily import certificates into ACM and use like an AWS-generated certificate. The only drawback is that it will **not** renew automatically like the AWS ones.

## List of ACM Certificates per Account

{%- for workspace_name, workspace in outputs.network.items() %}

### Account {{ stacks.platform.workspaces[workspace_name].account_name }} ({{ stacks.platform.workspaces[workspace_name].aws_account_id }})

| Region | Name | Domains | ARN |
| ------ | ---- | ------- | --- |
{%- for certificate_name, certificate in workspace.acm_certificate.items() %}
| {{ stacks.platform.workspaces[workspace_name].aws_region }} | {{ certificate_name }} | {{ certificate.dns_validation_records|map(attribute='domain_name') |join(',') }} | {{ certificate.arn }}
{%- endfor %}
{%- for certificate_name, certificate in workspace.acm_certificate_global.items() %}
| global (us-east-1) | {{ certificate_name }} | {{ certificate.dns_validation_records|map(attribute='domain_name') |join(',') }} | {{ certificate.arn }}
{%- endfor %}
{%- endfor %}