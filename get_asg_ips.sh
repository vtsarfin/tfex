#!/bin/bash
ASG=$1
QUERY='Reservations[*].Instances[*].{"private_ip":PrivateIpAddress,"public_ip":PublicIpAddress}'
echo $ASG
aws ec2 describe-instances --filters Name=tag:Name,Values=${ASG} --query ${QUERY}
