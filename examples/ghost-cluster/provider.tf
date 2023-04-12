provider aws {
  region              = local.region
  allowed_account_ids = local.allowed_account_ids
  profile             = var.profile

  default_tags {
    tags = {
      # Environment = local.env
      Maintainer  = local.maintainer
      # Namespace   = local.stack
      Generator   = "terraform"
    }
  }
}

terraform {
  required_version = ">= 1.4.4"
  backend "local" {
    path = "terraform.tfstate"
  }
}
