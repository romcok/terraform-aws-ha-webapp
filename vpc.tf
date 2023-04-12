module vpc {
  source      = "./modules/vpc"
  name        = "vpc"
  group       = "network"
  namespace   = var.name
  environment = var.environment

  cidr_block           = var.network.cidr_block
  availability_zones   = var.network.availability_zones
  public_subnet_cidrs  = var.network.public_subnet_cidrs
  private_subnet_cidrs = var.network.private_subnet_cidrs
}
