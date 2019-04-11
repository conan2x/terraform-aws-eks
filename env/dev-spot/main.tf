# eks

terraform {
  backend "s3" {
    region = "ap-northeast-2"
    bucket = "terraform-nalbam-seoul"
    key    = "eks-spot.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "eks" {
  source = "../../modules/eks"

  region = "ap-northeast-2"
  city   = "SEOUL"
  stage  = "DEV"
  name   = "SPOT"
  suffix = "EKS"

  vpc_id = "vpc-0c9725a980c28cbf3"

  subnet_ids = [
    "subnet-00b78569ce3ddef67",
    "subnet-027cf36a33643a7a2",
  ]

  launch_efs_enable = true

  launch_configuration_enable = false
  launch_template_enable      = true

  instance_type = "m5.large"

  volume_size = "32"

  min = "1"
  max = "5"

  on_demand_base = "0"
  on_demand_rate = "25"

  key_name = "nalbam-seoul"

  allow_ip_address = [
    "10.10.1.0/24",   # bastion
  ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SEOUL-DEV-DEMO-BASTION"
      username = "iam_role_bastion"
      group    = "system:masters"
    },
  ]

  map_users = [
    {
      user     = "user/admin"
      username = "iam_user_admin"
      group    = "system:masters"
    },
    {
      user     = "user/dev"
      username = "iam_user_dev"
      group    = "system:masters"
    },
  ]
}

data "aws_caller_identity" "current" {}

output "config" {
  value = "${module.eks.config}"
}
