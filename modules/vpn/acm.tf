resource aws_acm_certificate server {
  private_key      = var.server_private_key
  certificate_body = var.server_certificate
  certificate_chain = var.certificate_authority

  tags = module.label.tags
}

resource aws_acm_certificate client_root {
  private_key      = var.client_private_key
  certificate_body = var.client_certificate
  certificate_chain = var.certificate_authority

  tags = module.label.tags
}
