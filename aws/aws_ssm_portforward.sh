#!/usr/local/env bash

INSTANCE_ID="i-0a617<snip>"
REGION="us-east-1"
# LOCAL_PORT  and REMOTE_PORT you will need to manually edit becase of the single quotes
#  required to have a nice json
aws ssm start-session \
    --target "${INSTANCE_ID}" \
    --region "${REGION}" \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["30734"],"localPortNumber":["9999"]}'