#!/usr/bin/env bash

function aws.ec2.print-one {
  aws ec2 describe-instances \
      --region us-east-1 \
      --output text  \
      --query 'Reservations[].Instances[].[PublicIpAddress, InstanceId, Tags[].Value]'
#      --query 'Reservations[].Instances[]'
}

aws.ec2.print-one
