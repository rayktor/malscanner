terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.49.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.target_env
      Project     = var.project_code
      Author      = "Hitankar Ray"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = var.target_env
      Project     = var.project_code
      Author      = "Hitankar Ray"
    }
  }
}

locals {
  namespace        = "${var.project_code}-${var.target_env}"
  malscanner  = "${local.namespace}-malscanner"
}
