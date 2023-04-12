locals {
  database_name      = replace(title("${module.label.id}-db"), "-", "")
  master_availability_zone = element(slice(var.availability_zones, 0, 1), 0)
  read_replica_availability_zones = slice(var.availability_zones, 1, length(var.availability_zones))
}