provider "aws" {
  default_tags {
    tags = local.tags
  }
}

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  region     = data.aws_region.this.region
  account_id = data.aws_caller_identity.this.account_id
}
