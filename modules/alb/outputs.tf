output target_group_id {
  value = aws_alb_target_group.http.id
}

output target_group_arn {
  value = aws_alb_target_group.http.arn
}

output port {
  value = aws_alb_listener.http.port
}


output dns_name {
  value = aws_alb.main.dns_name
}

output url {
  value = "http://${aws_alb.main.dns_name}"
}