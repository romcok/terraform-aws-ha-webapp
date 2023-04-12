locals {
  allowed_account_ids = ["911921360950"] /* PUT YOUR AWS ACCOUNT ID HERE */
  env                 = "prod"
  region              = "us-east-1"
  name               = "ghost"
  group               = "root"
  maintainer          = "Roman Novak - hello@romcok.com"
}

resource random_string database_password {
  length  = 41
  special = false
}

resource aws_ssm_parameter url {
  name  = "/${local.env}/${local.name}/url"
  type  = "String"
  value = "https://${aws_cloudfront_distribution.ghost.domain_name}"
}

module ghost_cluster {
  source      = "../.."
  name        = local.name
  environment = local.env
  region      = local.region

  network = {
    cidr_block           = "10.0.0.0/16"
    availability_zones   = ["${local.region}a", "${local.region}b", "${local.region}c"]
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  }

  container = {
    port               = 2368
    image              = "ghost:latest"
    env_vars           = {
      NODE_ENV                   = "production"
      database__client           = "mysql"
      database__connection__host = "__DB_CLUSTER_ENDPOINT__"
      database__connection__user = "__DB_USERNAME__"
      database__connection__password = "__DB_PASSWORD__"
      database__connection__database = "__DB_NAME__"
    }
    secrets            = {
      url = aws_ssm_parameter.url.arn
    }
    cpu                = 512
    memory             = 1024
    count              = 3
    volume_root        = "/"
    mount_paths        = [ "/var/lib/ghost/content" ]
    health_check_path  = "/ghost/api/admin/site/"
  }

  database = {
    engine                  = "mysql"
    version                 = "8.0.mysql_aurora.3.03.0"
    instance                = "db.t4g.medium"
    port                    = 3306
    backup_retention_period = 7
    skip_final_snapshot     = true
    username                = "root"
    password                = random_string.database_password.result
  }

  vpn = {
    enabled               = true
    cidr_block            = "10.1.0.0/16"
    server_private_key    = file("./vpn-certs/server.key")
    server_certificate    = file("./vpn-certs/server.crt")
    client_private_key    = file("./vpn-certs/client.key")
    client_certificate    = file("./vpn-certs/client.crt")
    certificate_authority = file("./vpn-certs/ca.crt")
  }
}
