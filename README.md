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
Error: unknown flag: --hide
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
