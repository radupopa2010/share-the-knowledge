#!/usr/bin/env bash


function aws.ec2.print-one {
  local region
  region=$1
  aws ec2 describe-instances \
      --region "${region}" \
      --output text  \
      --query 'Reservations[].Instances[].[PublicIpAddress, InstanceId, Tags[].Value]'
#      --query 'Reservations[].Instances[]'
}

aws.ec2.print-one "us-east-1"
