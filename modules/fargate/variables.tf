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

variable region {
  type = string
}

variable task_memory {
  type = number
}

variable task_cpu {
  type = number
}

variable task_stament {
  type = string
}

variable desired_count {
  type = number
}

/*variable container_name {
  type = string
}*/

variable container_port {
  type = number
}

variable container_image {
  type = string
}

variable container_mount_points {
  type = list(object({
    name = string
    path = string
  }))
}

variable host_port {
  type    = number
  default = 0
}

variable container_environment {
  type = list(any)
}

variable container_secrets {
  type = list(object({
    name = string
    valueFrom = string
  }))
}

variable vpc_id {
  type = string
}

variable use_security_group_id {
  type = string
}

variable availability_zones {
  type = list(string)
}

variable subnet_ids {
  type = list(string)
}

variable target_group_arn {
  type = string
}

variable volumes {
  default = []
  type = list(object({
    name              = string
    security_group_id = string
    file_system_id    = string
    root_directory    = string
    access_point_id   = string
    /*efs = list(object({
      file_system_id = string
      root_directory = string
    }))*/
  }))
}
