#!/bin/bash

VALID_IPS=$1
INVALID_IPS=$2
IMDS_TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300"`
INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" http://169.254.169.254/latest/meta-data/instance-id`
ASSIGNED_EIP_COUNT=`aws ec2 describe-addresses --filters "Name=instance-id,Values=${INSTANCE_ID}" | jq '.Addresses | length'`
if [ "$ASSIGNED_EIP_COUNT" -gt 1 ]; then
  exit 0
fi

# comma-separated IPs as '52.41.69.16,54.184.227.90,54.214.34.82'
AVAILABLE_IPS=`aws ec2 describe-addresses | jq -r '[.Addresses[] | select(.NetworkInterfaceId == null and .InstanceId == null and .Domain == "vpc") | .PublicIp] | join(",")'`
# Choose random valid and available IP
AVAILABLE_IP=`ruby ./assign_eip.rb ${AVAILABLE_IPS} ${VALID_IPS} ${INVALID_IPS}`
# Fetch AllocationId of the Elastic IP Address as it is required for association
ALLOCATION_ID=`aws ec2 describe-addresses --filters "Name=public-ip,Values=${AVAILABLE_IP}" --query "Addresses[0].AllocationId" --output text`

aws ec2 associate-address --allocation-id ${ALLOCATION_ID} --instance-id ${INSTANCE_ID} --allow-reassociation false
