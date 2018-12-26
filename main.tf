# eks

terraform {
  backend "s3" {
    region = "ap-northeast-2"
    bucket = "terraform-nalbam-seoul"
    key    = "eks.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"
}

module "eks" {
  source = "./modules/eks"

  region = "${var.region}"
  city   = "${var.city}"
  stage  = "${var.stage}"
  name   = "${var.name}"

  cidr_block = "10.11.0.0/16"

  instance_type = "m4.large"
  desired       = "2"
  min           = "2"
  max           = "5"

  key_path   = ""               # ~/.ssh/id_rsa.pub
  key_name   = "nalbam-tokyo"   # nalbam-tokyo
  admin_cidr = "58.151.93.9/32" # $(curl icanhazip.com)/32
}

output "config" {
  value = "${module.eks.config}"
}
