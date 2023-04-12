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
variable cidr_block {
  type = string
}

variable availability_zones {
  type = list(string)
}

variable public_subnet_cidrs {
  type = list(string)
}

variable private_subnet_cidrs {
  type = list(string)
}