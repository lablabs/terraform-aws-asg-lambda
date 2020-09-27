variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "name" {
  type        = string
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "lambda_asg_target_names" {
  description = "List of ASG names for lambda invocation"
  type        = list(string)
  default     = []
}

variable "lambda_log_retention" {
  description = "Specifies the number of days you want to retain lambda log events. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = string
  default     = 0
}

variable "lambda_function_zip_base_url" {
  type        = string
  description = "Base URL of zip file with lambda function code. Path part with version number (see `lambda_function_version` variable) will be added automatically)"
  default     = "https://github.com/lablabs/terraform-aws-asg-lambda/releases/download/"
}

variable "lambda_function_zip_filename" {
  type        = string
  description = "Filename of zip file with lambda function code. Version number (see `lambda_function_version` variable) and `.zip` extension will be added automatically."
  default     = "aws-asg-lambda-"
}

variable "lambda_function_version" {
  type        = string
  default     = "0.0.2"
  description = "Version of lambda function. See https://github.com/lablabs/aws-asg-lambda/releases"
}

variable "eip_attach" {
  type        = bool
  default     = false
  description = "Whetever to attach EIP to instance or not"
}

variable "eni_attach" {
  type        = bool
  default     = false
  description = "Whetever to attach ENI to instance or not"
}

variable "ebs_attach" {
  type        = bool
  default     = false
  description = "Whetever to attach EBS volume to instance or not"
}

variable "eip_tag_filter_name" {
  description = "Name of the EIP tag name for resource filtering"
  type        = string
  default     = ""
}

variable "eip_tag_filter_value" {
  description = "Value of the EIP tag for resource filtering"
  type        = string
  default     = ""
}

variable "eni_tag_filter_name" {
  description = "Name of the ENI tag name for resource filtering"
  type        = string
  default     = ""
}

variable "eni_tag_filter_value" {
  description = "Value of the ENI tag for resource filtering"
  type        = string
  default     = ""
}

variable "ebs_tag_filter_name" {
  description = "Name of the EBS tag name for resource filtering"
  type        = string
  default     = ""
}

variable "ebs_tag_filter_value" {
  description = "Value of the EBS tag for resource filtering"
  type        = string
  default     = ""
}

variable "ebs_device_name" {
  description = "The device name to expose to the instance"
  type        = string
  default     = "/dev/xvdz"
}
