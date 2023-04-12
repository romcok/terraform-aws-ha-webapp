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

variable vpc_id {
  type = string
}

variable subnet_ids {
  type = list(string)
}

variable use_security_group_id {
  type = string
}

variable health_check_path {
  type = string
}

variable target_port {
  type = number
}

variable internal {
  type = bool
  default = false
}