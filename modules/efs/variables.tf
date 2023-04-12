# Module
variable name {
  type = string
}

variable group {
  type = string
}

variable namespace {
  type = string
}

variable environment {
  type = string
}

# Network
variable subnet_ids {
  type = list(string)
}

variable use_security_group_id {
  type = string
}

variable root_path {
  type = string
}