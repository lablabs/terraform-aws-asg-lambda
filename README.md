# aws-asg-lambda

[![Labyrinth Labs logo](ll-logo.png)](https://www.lablabs.io)

We help companies build, run, deploy and scale software and infrastructure by embracing the right technologies and principles. Check out our website at https://lablabs.io/

---

![Terraform validation](https://github.com/lablabs/terraform-aws-asg-lambda/workflows/Terraform%20validation/badge.svg?branch=master)
![Python validation](https://github.com/lablabs/terraform-aws-asg-lambda/workflows/Python%20validation/badge.svg?branch=master)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-success?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Latest Release](https://img.shields.io/github/release/lablabs/terraform-aws-asg-lambda.svg)](https://github.com/lablabs/terraform-aws-asg-lambda/releases/latest)


## Description
The asg-lambda, manages the assignment of a multiple AWS resources to the instances belonging to one or more ASG (AWS autoscaling groups). Supported resources are:
* EIP
* ENI
* EBS

You can pre-allocate an AWS resources (EIP/ENI/EBS) and assign custom tags to create virtual pools of AWS resources. The lambda can consume free resources from pools and assign them to the instance when starting. When the instance is terminated, the resources are released and re-used. Lambda works only with the instances that belong to one or more ASGs defined in lambda_asg_target_names.

Module creates an EC2 Auto Scaling lifecycle hooks to put the instance into a wait state whenever your Auto Scaling group scales and set the EventBridge rule to trigger asg-lamba on EC2 Instance-launch Lifecycle Action.

## Related projects

### aws-sf-lambda

A lambda function which is used for attaching of static ENIs and EBS volumes to
an EC2 instance launched by AWS ASGs.

URL: https://github.com/lablabs/aws-sf-lambda

## Examples

See [Basic example](examples/basic/README.md) for further information.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |
| null | n/a |
| template | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| label | cloudposse/label/null | 0.24.1 |

## Resources

| Name |
|------|
| [aws_autoscaling_lifecycle_hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) |
| [aws_cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) |
| [aws_cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) |
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) |
| [aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| ebs\_attach | Whetever to attach EBS volume to instance or not | `bool` | `false` | no |
| ebs\_device\_name | The device name to expose to the instance | `string` | `"/dev/xvdz"` | no |
| ebs\_tag\_filter\_name | Name of the EBS tag name for resource filtering | `string` | `""` | no |
| ebs\_tag\_filter\_value | Value of the EBS tag for resource filtering | `string` | `""` | no |
| eip\_attach | Whetever to attach EIP to instance or not | `bool` | `false` | no |
| eip\_tag\_filter\_name | Name of the EIP tag name for resource filtering | `string` | `""` | no |
| eip\_tag\_filter\_value | Value of the EIP tag for resource filtering | `string` | `""` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| eni\_attach | Whetever to attach ENI to instance or not | `bool` | `false` | no |
| eni\_tag\_filter\_name | Name of the ENI tag name for resource filtering | `string` | `""` | no |
| eni\_tag\_filter\_value | Value of the ENI tag for resource filtering | `string` | `""` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | `string` | `""` | no |
| lambda\_asg\_target\_names | List of ASG names for lambda invocation | `list(string)` | `[]` | no |
| lambda\_function\_version | Version of lambda function. See https://github.com/lablabs/aws-asg-lambda/releases | `string` | `"0.0.2"` | no |
| lambda\_function\_zip\_base\_url | Base URL of zip file with lambda function code. Path part with version number (see `lambda_function_version` variable) will be added automatically) | `string` | `"https://github.com/lablabs/terraform-aws-asg-lambda/releases/download/"` | no |
| lambda\_function\_zip\_filename | Filename of zip file with lambda function code. Version number (see `lambda_function_version` variable) and `.zip` extension will be added automatically. | `string` | `"aws-asg-lambda-"` | no |
| lambda\_log\_retention | Specifies the number of days you want to retain lambda log events. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `string` | `0` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `""` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `""` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `""` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_event\_rule\_attributes | CloudWatch Event Rule resource attributes |
| labmda\_iam\_role\_attributes | Lambda iam role attributes |
| lambda\_function\_attributes | ASG lambda attributes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Contributing and reporting issues

Feel free to create an issue in this repository if you have questions, suggestions or feature requests.

### Validation, linters and pull-requests

We want to provide high quality code and modules. For this reason we are using
several [pre-commit hooks](.pre-commit-config.yaml) and
[GitHub Actions workflow](.github/workflows/main.yml). A pull-request to the
master branch will trigger these validations and lints automatically. Please
check your code before you will create pull-requests. See
[pre-commit documentation](https://pre-commit.com/) and
[GitHub Actions documentation](https://docs.github.com/en/actions) for further
details.


## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
