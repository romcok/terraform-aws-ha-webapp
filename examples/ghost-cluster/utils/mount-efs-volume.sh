#!/bin/bash

VOLUME_MOUNT_IP=$1

mkdir -p /Volumes/efs
mount -t nfs -o vers=4,tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 -w $VOLUME_MOUNT_IP:/ /Volumes/efs