output ghost_cluster {
  # sensitive = false
  value = module.ghost_cluster
}

output domain_name {
  value = aws_cloudfront_distribution.ghost.domain_name
}