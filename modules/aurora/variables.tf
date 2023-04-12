# Module
variable name {
  type = string
}

variable namespace {
  type = string
}

variable environment {
  type = string
}

variable group {
  type = string
}

# Network
variable availability_zones {
  type = list(string)
}

variable use_security_group_id {
  type = string
}

variable subnet_ids {
  type = list(string)
}

variable vpc_id {
  type = string
}

# Database
variable instance_class {
  type = string
}

variable engine {
  type = string
  default = "mysql"
}

variable engine_version {
  type = string
}

variable backup_retention_period {
  type = number
}

variable skip_final_snapshot {
  type = bool
  default = false
}

variable database_username {
  type = string
}

variable database_password {
  type = string
}