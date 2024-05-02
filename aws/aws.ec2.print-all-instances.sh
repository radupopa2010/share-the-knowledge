#!/usr/bin/env bash

function aws.ec2.print-all-instances() {
  REGIONS=$(aws ec2 describe-regions --region us-east-1 --output text --query Regions[*].[RegionName])
  for REGION in $REGIONS ; do
    echo -e "\nInstances in '$REGION'..";
    aws ec2 describe-instances \
	    --region $REGION \
	    --output json \
            --query 'Reservations[].Instances[].[PublicIpAddress, InstanceId, Tags[].Value]'
           #  --query 'Reservations[].Instances[].PublicIpAddress'
      #| jq '"Reservations[].Instances[].PublicIpAddress"'
  done
}

aws.ec2.print-all-instances
