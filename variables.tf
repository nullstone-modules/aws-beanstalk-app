variable "stack" {
  type = string

  description = <<EOF
The preconfigured application stack to launch.
Use `aws elasticbeanstalk list-available-solution-stacks` to view available.
See https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
EOF
}

variable "instance_type" {
  type        = string
  default     = "t3.nano"
  description = <<EOF
Instance Type that dictates CPU, Memory, network bandwidth, and file storage type and bandwidth.
See https://aws.amazon.com/ec2/instance-types/ for EC2 instance types.
EOF
}

variable "minimum_instances" {
  type        = number
  default     = 1
  description = <<EOF
The minimum number of instances that you want.
See https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.managing.as.html for details on autoscaling
EOF
}

variable "maximum_instances" {
  type        = number
  default     = 4
  description = <<EOF
The maximum number of instances that you want.
See https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.managing.as.html for details on autoscaling
EOF
}
