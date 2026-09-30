variable "env_vars" {
  type        = map(string)
  default     = {}
  description = <<EOF
The environment variables to inject into the service.
These are typically used to configure a service per environment.
It is dangerous to put sensitive information in this variable because they are not protected and could be unintentionally exposed.
EOF
}

variable "secrets" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = <<EOF
The sensitive environment variables to inject into the service.
These are typically used to configure a service per environment.
EOF
}

locals {
  standard_env_vars = tomap({
    NULLSTONE_STACK         = data.ns_workspace.this.stack_name
    NULLSTONE_APP           = data.ns_workspace.this.block_name
    NULLSTONE_ENV           = data.ns_workspace.this.env_name
    NULLSTONE_VERSION       = data.ns_app_env.this.version
    NULLSTONE_COMMIT_SHA    = data.ns_app_env.this.commit_sha
    NULLSTONE_PUBLIC_HOSTS  = join(",", local.public_hosts)
    NULLSTONE_PRIVATE_HOSTS = join(",", local.private_hosts)
  })
}

// ns_env_layout classifies secrets using keys only, so the set of secrets to add to aws secrets manager is known at plan time
data "ns_env_layout" "this" {
  platform               = "aws_beanstalk"
  standard_keys          = keys(local.standard_env_vars)
  capability_env_keys    = [for e in local.cap_env : { capability = e.capability, name = e.name }]
  capability_secret_keys = [for s in local.cap_secrets : { capability = s.capability, name = s.name }]
  capability_prefixes    = local.cap_prefixes
  user_env               = var.env_vars
  user_secret_keys       = nonsensitive(keys(var.secrets))
}

data "ns_env_values" "this" {
  platform            = "aws_beanstalk"
  standard            = local.standard_env_vars
  capability_env      = local.cap_env
  capability_secrets  = local.cap_secrets
  capability_prefixes = local.cap_prefixes
  user_env            = var.env_vars
  user_secrets        = var.secrets
}

// ns_env_platform_data records where each managed secret lives so Nullstone can display the environment
data "ns_env_platform_data" "this" {
  values     = data.ns_env_values.this.platform_data
  secret_ids = { for key, secret in aws_secretsmanager_secret.app_secret : key => secret.arn }
}

locals {
  all_env_vars = merge(data.ns_env_values.this.env_variables, local.app_secret_ids)
}
