resource "aws_elastic_beanstalk_application" "this" {
  name = local.resource_name
  tags = local.tags
}

resource "aws_elastic_beanstalk_environment" "this" {
  application         = aws_elastic_beanstalk_application.this.name
  name                = local.env_name
  tags                = local.tags
  solution_stack_name = var.stack
  tier                = "WebServer"

  // Settings Reference: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = local.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", local.private_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", local.public_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.this.arn
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = join(",", [aws_security_group.this.id])
  }
}
