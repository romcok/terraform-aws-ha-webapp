variable name {
  type = string
}

variable environment {
  type = string
}

variable region {
  type = string
}

variable network {
  type = object({
    cidr_block = string
    availability_zones = list(string)
    public_subnet_cidrs = list(string)
    private_subnet_cidrs = list(string)
  })
}

variable vpn {
  type = object({
    enabled = bool
    cidr_block = string
    server_private_key = string
    server_certificate = string
    client_private_key = string
    client_certificate = string
    certificate_authority = string
  })
}

variable container {
  type = object({
    port = number
    image = string
    env_vars = map(string)
    secrets = map(string)
    cpu = number
    memory = number
    count = number
    volume_root = string
    mount_paths = list(string)
    health_check_path = string
  })
}

variable database {
  type = object({
    username = string
    password = string
    engine = string
    port   = number
    version = string
    instance = string
    backup_retention_period = string
    skip_final_snapshot = bool
  })
}