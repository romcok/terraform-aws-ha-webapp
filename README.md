# Terraform Multi-AZ Web Application Deployment Module for AWS
This terraform module deploys applications with an ALB, VPN, ECS Fargate Cluster, and an Aurora Cluster in multiple Availability Zones (AZs) on AWS.

> **_DISCLAIMER:_**  This module is for presentation purposes only and does not rely on any external terraform modules. It's not full-featured (e.g. HTTP only), and should not be used for production deployments.

## Features
This module consists of the following parts:
- Application Load Balancer (ALB) for load balancing
- VPN for secure access to private resources
- ECS Fargate Cluster for running Docker containers
- Aurora Cluster for relational database storage
- Supports deployment in multiple availability zones


## Example
Review the [ghost blog example](examples/ghost-cluster) to see how to use this module.


## Usage

```hcl
resource random_string database_password {
  length  = 41
  special = false
}

module "multi_az_blog" {
  source = "git::https://github.com/romcok/terraform-aws-ha-webapp.git"

  name        = "blog"
  environment = "prod"
  region      = "us-east-1"

  network = {
    cidr_block           = "10.0.0.0/16"
    availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  }

  container = {
    port               = 2368
    image              = "ghost:latest"
    env_vars           = {
      NODE_ENV                   = "production"
      database__client           = "mysql"
      database__connection__host = "__DB_CLUSTER_ENDPOINT__"
      database__connection__user = "__DB_USERNAME__"
      database__connection__password = "__DB_PASSWORD__"
      database__connection__database = "__DB_NAME__"
    }
    cpu                = 512
    memory             = 1024
    count              = 3
    volume_root        = "/"
    mount_paths        = [ "/var/lib/ghost/content" ]
    health_check_path  = "/ghost/api/admin/site/"
  }

  database = {
    engine                  = "mysql"
    version                 = "8.0.mysql_aurora.3.03.0"
    instance                = "db.t4g.medium"
    port                    = 3306
    backup_retention_period = 7
    skip_final_snapshot     = true
    username                = "root"
    password                = random_string.database_password.result
  }

  vpn = {
    enabled               = true
    cidr_block            = "10.1.0.0/16"
    server_private_key    = file("./vpn-certs/server.key")
    server_certificate    = file("./vpn-certs/server.crt")
    client_private_key    = file("./vpn-certs/client.key")
    client_certificate    = file("./vpn-certs/client.crt")
    certificate_authority = file("./vpn-certs/ca.crt")
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.62 |

## Inputs
| Name | Parameter   | Description | Type |
|------|-------------|-------------|:----:|
| <a name="input_name"></a> [name](#input\_name) | | Module name | `string` |
| <a name="input_environment"></a> [environment](#input\_environment) | | Environment (`dev`, `prod`..) | `string` |
| <a name="input_region"></a> [region](#input\_region) | | Deployment region  | `string` |
| <a name="input_network"></a> [network](#input\_network) | | VPC network configuration | `object` |
| | <a name="input_network_cidr_block"></a> [cidr_block](#input\_network\_cidr_block) | VPC IPv4 CIDR block | `network` |
| | <a name="input_network_availability_zones"></a> [availability_zones](#input\_network\_availability_zones) | List of availability zones | `list(string)` |
| | <a name="input_network_public_subnet_cidrs"></a> [public_subnet_cidrs](#input\_network\_public_subnet_cidrs) | Public subnet IPv4 CIDR block per AZ | `list(string)` |
| | <a name="input_network_private_subnet_cidrs"></a> [private_subnet_cidrs](#input\_network\_private_subnet_cidrs) | Private subnet IPv4 CIDR block per AZ | `list(string)` |
| <a name="input_container"></a> [container](#input\_container) | | ECS Fargate configuration | `object` |
| | <a name="input_container_port"></a> [port](#input\_container\_port) | Container port number | `number` |
| | <a name="input_container_image"></a> [image](#input\_container\_image) | Docker image | `string` |
| | <a name="input_container_env_vars"></a> [env_vars](#input\_container\_env_vars) | List of environment Variables | `map(string)` |
| | <a name="input_container_secrets"></a> [secrets](#input\_container\_secrets) | List of SSM paramaters | `map(string)` |
| | <a name="input_container_cpu"></a> [cpu](#input\_container\_cpu) | Task CPU allocation | `number` |
| | <a name="input_container_memory"></a> [memory](#input\_container\_memory) | Task memory allocation | `number` |
| | <a name="input_container_count"></a> [count](#input\_container\_count) | Number of desired tasks | `number` |
| | <a name="input_container_volume_root"></a> [volume_root](#input\_container\_volume_root) | EFS volume root path | `string` |
| | <a name="input_container_mount_paths"></a> [mount_paths](#input\_container\_mount_paths) | Container mapping paths | `map(string)` |
| | <a name="input_container_health_check_path"></a> [healt_check_path](#input\_container\_healt_check_path) | Container health check path | `string` |
| <a name="input_database"></a> [database](#input\_database) | | Database configuration | `object` |
| | <a name="input_database_username"></a> [username](#input\_database\_username) | Database username | `string` |
| | <a name="input_database_password"></a> [password](#input\_database\_password) | Databvase password | `string` |
| | <a name="input_database_engine"></a> [engine](#input\_database\_engine) | Aurora RDS engine (`mysql` or `postgres`) | `string` |
| | <a name="input_database_port"></a> [port](#input\_database\_port) | Database port (3306 for `mysql`) | `number` |
| | <a name="input_database_version"></a> [version](#input\_database\_version) | Aurora RDS version | `string` |
| | <a name="input_database_instance"></a> [instance](#input\_database\_instance) | Aurora RDS instance class | `string` |
| | <a name="input_database_backup_retention_period"></a> [backup_retention_period](#input\_database\_backup_retention_period) | Database backup retention period in days | `number` |
| | <a name="input_database_skip_final_snapshot"></a> [skip_final_snapshot](#input\_database\_skip_final_snapshot) | Indicates whether to skip the last snapshot before destruction | `bool` |
| <a name="input_vpn"></a> [vpn](#input\_vpn) | | Client VPN configuration | `object` |
| | <a name="input_vpn_enabled"></a> [enabled](#input\_vpn\_enabled) | Indicates whether Client VPN service should be configured  | `bool` |
| | <a name="input_vpn_cidr_block"></a> [cidr_block](#input\_vpn\_cidr_block) | Client VPN IPv4 CIDR block | `string` |
| | <a name="input_vpn_server_private_key"></a> [server_private_key](#input\_vpn\_server_private_key) | Server private key | `string` |
| | <a name="input_vpn_server_certificate"></a> [server_certificate](#input\_vpn\_server_certificate) | Server certificate | `string` |
| | <a name="input_vpn_client_private_key"></a> [client_private_key](#input\_vpn\_client_private_key) | Client private key | `string` |
| | <a name="input_vpn_client_certificate"></a> [client_certificate](#input\_vpn\_client_certificate) | Client certificate | `string` |
| | <a name="input_vpn_certificate_authority"></a> [certificate_authority](#input\_vpn\_certificate_authority) | Certificate authority | `string` |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb_dns_name](#output\_alb_dns_name) | ALB dns name |
| <a name="output_database_cluster_endpoint"></a> [database_cluster_endpoint](#output\_database_master_endpoint) | Aurora cluster endpoint |
| <a name="output_database_cluster_reader_endpoint"></a> [database_cluster_reader_endpoint](#output\database_cluster_reader_endpoint) | Aurora cluster reader endpoint |
| <a name="output_database_endpoints"></a> [database_endpoints](#output\_database_endpoints) | List of all aurora instance endpoints |
| <a name="output_database_master_endpoint"></a> [database_master_endpoint](#output\_database_master_endpoint) | Aurora cluster master instance endpoint |
| <a name="output_database_read_replica_endpoints"></a> [database_read_replica_endpoints](#output\_database_read_replica_endpoints) | List of aurora cluster read replica endpoints |
| <a name="output_database_username"></a> [database_username](#output\_database_username) | Database username |
| <a name="output_database_name"></a> [database_name](#output\_database_name) | Auora cluster database name |
| <a name="output_volume_dns_name"></a> [volume_dns_name](#output\_volume_dns_name) | EFS volume dns name |
| <a name="output_volume_access_point_id"></a> [volume_access_point_id](#output\_volume_access_point_id) | EFS volume access point id |
| <a name="output_volume_mount_target_ips"></a> [volume_mount_target_ips](#output\_volume_mount_target_ips_) | ECS volume mount target IPv4 adresses |
| <a name="output_vpn_id"></a> [vpn_id](#output\_vpn_id) | ID of Client VPN endpoint |
| <a name="output_vpn_arn"></a> [vpn_arn](#output\_vpn_arn) | ARN of Client VPN endpoint |
| <a name="output_vpn_dns_name"></a> [vpn_dns_name](#output\_vpn_dns_name) | Client VPN DNS name |
| <a name="output_ecs_cluster_name"></a> [ecs_cluster_name](#output\_ecs_cluster_name) | ECS fargate cluster name |
| <a name="output_ecs_service_name"></a> [ecs_service_name](#output\_ecs_service_name) | ECS fargate service name |
| <a name="output_ecs_container_name"></a> [ecs_container_name](#output\_ecs_container_name) | ECS fargate container name |

## Environment Variable Replacements
Certain placeholders are used to represent environment-specific values within environment variables. These placeholders will be replaced with the appropriate values during the deployment or runtime of the ECS Fargate tasks. Here is the list of placeholders:

| Name                     | Description                                         |
|--------------------------|-----------------------------------------------------|
|__ALB_URL__               | ALB HTTP URL (`http://<alb_dns_name>`)              |
| __DB_NAME__              | Database name                                       |
| __DB_USERNAME__          | Database username                                   |
| __DB_PASSWORD__          | Database password                                   |
| __DB_CLUSTER_ENDPOINT__  | Aurora cluster load-balanced endpoint               |
| __DB_MASTER_ENDPOINT__   | Aurora master instance endpoint                     |
| __DB_READER_ENDPOINT__   | Aurora cluster load-balanced reader endpoint        |
| __DB_REPLICAS_ENDPOINT__ | Comma separated database replica endpoints          |
| __DB_ENDPOINTS__         | Comma separated list of database instance endpoints |

## TODO
The following items are areas of improvement and additional features that can be added to the module in the future:
- Update the ALB listener to use the SSL certificate and configure HTTPS connections.
- Implement auto-scaling for the ECS Fargate tasks to handle varying levels of traffic and ensure optimal resource utilization.
- Evaluate and implement additional performance optimizations for the ECS tasks, such as caching strategies and content delivery networks (CDN).


## License
This module is released under the MIT License.

## Authors
| [![Roman Novák][romcok_avatar]][romcok_profile]<br/>[Roman Novák][romcok_profile] |
|---|

  [romcok_profile]: https://github.com/romcok
  [romcok_avatar]: https://avatars.githubusercontent.com/u/179070?s=150&v=4

---
Don't hesitate to open an issue or pull request if you find any issues or have suggestions for improvements. Your contributions are always welcome!
