resource aws_cloudwatch_log_group connection_log {
  name = "${module.label.id}-group"

  tags = module.label.tags
}

resource aws_cloudwatch_log_stream connection_log {
  name           = "${module.label.id}-stream"
  log_group_name = aws_cloudwatch_log_group.connection_log.name
}