module "label" {
  source  = "cloudposse/label/null"
  version = "0.19.2"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes = concat(
    ["lambda-asg"],
    var.attributes
  )
  tags = var.tags
}
