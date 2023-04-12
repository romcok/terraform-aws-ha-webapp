# Common
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

# Settings
variable vpc_id {
  type = string
}

variable description {
  type = string
  default = null
}

variable security_group_create_timeout {
  type = number
  default = null
}

variable security_group_delete_timeout {
  type = number
  default = null
}

variable ingress_all {
  type = bool
  default = false
}

variable egress_all {
  type = bool
  default = false
}

variable ingress {
  type = list(object({
    name        = string
    cidr_block  = string
    description = string
    from_port   = number
    to_port     = number
    protocol = string
    security_group_id = string
  }))
  default = []
}

variable egress {
  type = list(object({
    name        = string
    cidr_block  = string
    description = string
    from_port   = number
    to_port     = number
    protocol = string
    security_group_id = string
  }))
  default = []
}