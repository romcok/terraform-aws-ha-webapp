output volume_id {
  value = aws_efs_file_system.volume.id
}

output volume_arn {
  value = aws_efs_file_system.volume.arn
}

output volume_dns_name {
  value = aws_efs_file_system.volume.dns_name
}

output access_point_id {
  value = aws_efs_access_point.volume.id
}

output mount_target_ips {
  value = aws_efs_mount_target.mount.*.ip_address
}