# Example Deployment of the Ghost blog cluster

This example demonstrates how to deploy a Ghost Cluster using this terraform module. The following steps will guide you through:
1. Generate certificates for Client VPN service
2. Deploy the cluster
3. View the blog website
4. Connect to the Client VPN
5. Mount the EFS volume on your local computer
6. Connect to the Database cluster
7. Execute a command in the ECS Fargate Task

> **_DISCLAIMER:_** This example is for demonstration purposes only. The connection between CloudFront and the Application Load Balancer is not secured, and it is not recommended for production environments. Also the load balancer works only on the HTTP port and the database credentials are not securely encrypted.

## Prerequisites

- Terraform installed
- Computer with macOS operating system and root access with `sudo` privileges (usage on linux distributions is similar)
- AWS CLI installed and configured with your AWS credentials (`https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html`)
- Installed Session Manager plugin for the AWS CLI (`https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html`)
- AWS Client VPN installed (`https://aws.amazon.com/vpn/client-vpn-download/`)
- Installed easy-rsa utility (`https://github.com/OpenVPN/easy-rsa` or `https://formulae.brew.sh/formula/easy-rsa`)
- Installed mysql-cli package or other MYSQL client (`https://formulae.brew.sh/formula/mysql-client`)

## Usage

### 1. Generate certificates for Client VPN
To generate client and server certificates for Client VPN service, you can use the simple script attached to this example. 

Here's how to generate certificates to connect to a VPC:
1. Install the `easy-rsa` utility if you don't already have it installed.
2. Execute the command `./utils/easyrsa-gen.sh` from your example working directory.
3. Provide `Common Name` for the certification authority.
4. Confirm server request details with `yes`
5. Confirm client request details with `yes`

> A `vpn-certs` directory should be created in your working directory with the generated certificates

### 2. Deploy terraform module
To deploy this terraform IaaC, first initialize your Terraform working directory:

```bash
terraform init
```

Then, apply the terraform configuration:
```bash
terraform apply
```

Confirm the deployment by entering `yes` when prompted. Terraform will create the necessary resources and output the relevant information described in the root of this repository.


### 3. View the Blog Website
After the deployment is completed, you can view the blog website using the CloudFront Distribution URL provided in the Terraform output `domain_name`. Open the URL in your browser.

### 4. Connect to the Client VPN
To connect to the Client VPN: 
1. Download and install ***AWS Client VPN*** from `https://aws.amazon.com/vpn/client-vpn-download/`
1. Open and login to AWS web console in your browser `https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#ClientVPNEndpoints:`
2. Click on `Download client configuration`
3. Copy and paste into downloaded-client-config.ovpn after </ca> the following parts:
    1. Enclose the contents of the client.crt file in `<cert>-----BEGIN CERT..</cert>`. Use only the part from `-----BEGIN CERTIFICATE-----`
    2. Enclose the contents of the client.key file in `<cert>-----BEGIN PRIV..</cert>`
4. Start the AWS Client VPN application
5. Go to the menu `File > Manage Profiles`
6. Click `Add profile`
7. Fill in any good name for `Display name` for `VPN Configuration File` choose the downloaded and modified `downloaded-client-config.ovpn` configuration file.
8. Click `Add profile`, `Done`, select a profile name from the list and click "Connect"

**Now, you should be connected to your VPC.**

### 5. Mount the EFS volume on your local computer
To mount the EFS volume on your local machine, you can use the simple script attached to this example. 

> Alternatively you could use `amazon-efs-utils` from `https://docs.aws.amazon.com/efs/latest/ug/using-amazon-efs-utils.html`

Here's how to mount an ECS volume to your file system:
1. Connect to the VPC via Client VPN (you are probably still connected from step 4)
2. Copy one of the ip addresses in `volume_mount_target_ips` from the output of your deployment from step 2.
3. Execute (from the directory of this example) the command `sudo ./utils/mount-efs-volume.sh <ip>`, where `<ip>` is the IP address you copied from the terraform output.
**You should now have a mapped EFS volume in the /Volumes/efs path**

> The volume is readonly for the GUI because you mounted it as root

> You can unmount the volume using the command `mount`, copy the mount path and `sudo umount /Volumes/efs`

### 6. Connect to the Database Cluster
To connect to the database cluster, use the database endpoint and credentials provided in the terraform outputs. You can use any MySQL client or the command-line client, to establish a connection.

The connection procedure via the command-line client (we will use the mysql-client package) is as follows:
1. Open and login to AWS web console in your browser `https://us-east-1.console.aws.amazon.com/ecs/v2/task-definitions?region=us-east-1`
2. Click on task definition, task revision, select tab `JSON`.
3. Use the following command to connect to the database: `mysql -h <database__connection__host> -u <database__connection__user> -p <database__connection__database>`. Replace the values in <> with the values that are specified in the environment in JSON.
> You are now connected and can use SQL to query the database (e.g. `SHOW TABLES;`). Close the console with `exit`

### 7. Execute a command in the ECS Fargate Task
To execute a command in the ECS Cluster task, you can use the AWS CLI or AWS Management Console. Here is an example using the AWS CLI:

1. Plase install the Session Manager plugin for the AWS CLI `https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html`
2. Execute command `aws ecs list-tasks --cluster <ecs_cluster_name> --region us-east-1` where ecs_cluster_name is copied from the terraform output.
3. Copy the value after the last `/` from one of the taskArn outputs
4. Execute the command `aws ecs execute-command --cluster <ECS_CLUSTER_NAME> --task <TASK_ID> --container <CONTAINER_NAME> --command "sh" --interactive --region us-east-1`. Use `ECS_CLUSTER_NAME` and `ECS_CONTAINER_NAME` from the terraform output and `TASK_ID` as the value from the previous step.
5. Now run the following commands to check the outgoing connection from the container:
    1. `apt update`
    2. `apt install iputils-ping`
    3. `ping -c google.com`
> If everything installed and the container pings google.com everything should be fine. Close the console with `exit`

## Conclusion
The provided example demonstrates how to deploy a complete infrastructure using terraform to host a web application with an ALB, VPN, ECS Fargate Cluster, and Aurora Cluster across three availability zones. The step-by-step guide helps users understand the process of deploying the infrastructure, connecting to the resources, and working with various services.

By following the steps in the guide and adjusting the terraform configuration as needed, users can easily set up a scalable and highly available infrastructure for their applications. This example serves as a solid foundation for further customization and improvements to meet specific use cases and requirements.

Hope you enjoyed it as much as I 👷
