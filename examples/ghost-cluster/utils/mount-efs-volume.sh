#!/bin/bash

VOLUME_DNS_NAME=$1
ACCESS_POINT_ID=$2

# Create mount path for volume
mkdir -p ./efs

# Mount EFS volume
# mount -t nfs -o vers=4,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,proto=tcp ${VOLUME_DNS_NAME}:/ /Volumes/efs
# mount -t nfs -o tls,accesspoint=$2 ${VOLUME_DNS_NAME}:/ /Volumes/efs
# mount.efs ${VOLUME_DNS_NAME}:/ /Volumes/efs -o tls
mount.efs ${VOLUME_DNS_NAME}:/ /Volumes/efs -o tls,accesspoint=${ACCESS_POINT_ID}
# mount -t nfs -o vers=4,tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 -w ${VOLUME_DNS_NAME}:/ efs

sudo mount -t nfs -o vers=4,tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 -w 10.0.10.39:/ /Volumes/efs

# To unmount use command:
# sudo umount /Volumes/efs

# brew tap aws/homebrew-aws
# arch -arm64 brew install amazon-efs-utils
# brew info amazon-efs-utils