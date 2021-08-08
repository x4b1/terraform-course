terraform {
  required_version = "~> 1.0"

  backend "s3" {
    bucket = "myapp-bucket"
    key    = "myapp/state.tfstate"
    region = "eu-west-1"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "xabi"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cdir_block

  azs                = [var.avail_zone]
  public_subnets     = [var.subnet_cidr_block]
  public_subnet_tags = { Name = "${var.env_prefix}-subnet-1" }

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


module "myapp-server" {
  source = "./modules/webserver"

  vpc_id              = module.vpc.vpc_id
  my_ip               = var.my_ip
  subnet_id           = module.vpc.public_subnets[0]
  image_name          = var.image_name
  public_key_location = var.public_key_location
  instance_type       = var.instance_type
  avail_zone          = var.avail_zone
  env_prefix          = var.env_prefix
}
