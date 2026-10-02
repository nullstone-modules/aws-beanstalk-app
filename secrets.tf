locals {
  // Since Beanstalk does not have secret injection, we are going to add a list of env vars mapping the secret ids
  // e.g. POSTGRES_URL => POSTGRES_URL_SECRET_ID = <secret-id>
  app_secret_ids = { for key, secret in aws_secretsmanager_secret.app_secret : "${key}_SECRET_ID" => secret.id }
}

resource "aws_secretsmanager_secret" "app_secret" {
  for_each = data.ns_env_layout.this.managed_secret_keys

  name_prefix = "${local.block_name}/${each.value}/"
  tags        = local.tags
  kms_key_id  = aws_kms_alias.this.arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "app_secret" {
  for_each = data.ns_env_layout.this.managed_secret_keys

  secret_id     = aws_secretsmanager_secret.app_secret[each.value].id
  secret_string = data.ns_env_values.this.secrets[each.value]

  lifecycle {
    create_before_destroy = true
  }
}

// setup for secrets manager permissions
locals {
  // These are used to generate an IAM policy statement to allow the app to read the secrets
  secret_arns                = [for as in aws_secretsmanager_secret.app_secret : as.arn]
  secret_statement_resources = length(local.secret_arns) > 0 ? [local.secret_arns] : []
}

resource "aws_iam_role_policy" "secrets" {
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.secrets.json
}

data "aws_iam_policy_document" "secrets" {
  statement {
    sid       = "AllowPassRoleToBeanstalk"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.this.arn]
  }

  dynamic "statement" {
    for_each = local.secret_statement_resources

    content {
      sid       = "AllowReadSecrets"
      effect    = "Allow"
      resources = statement.value

      actions = [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ]
    }
  }
}
