locals {
  // format("%s%s", var.environment, var.namespace ? "-${var.namespace}" : "")
  prefix = "${var.environment}${var.namespace == null ? "" : "-${var.namespace}"}"
  id     = "${local.prefix}-${var.name}"
  tags = merge(
    {
      Name        = local.id
      Namespace   = var.namespace
      Module      = var.module
      Group       = var.group
      Environment = var.environment
  }, var.tags)
}
