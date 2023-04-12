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
variable vpc_id {
  type = string
}

variable cidr_block {
  type = string
}

variable use_security_group_id {
  type = string
}

variable subnet_ids {
  type = list(string)
}

variable subnet_cidrs {
  type = list(string)
}

variable dns_servers {
  type = list(string)
}

# Certificates
variable server_private_key {
  type = string
}

variable server_certificate {
  type = string
}

variable client_private_key {
  type = string
}

variable client_certificate {
  type = string
}

variable certificate_authority {
  type = string
}