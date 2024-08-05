
INSTANCE_ID=i-09b194ff11b66ccdc
REGION=us-east-1

aws ssm start-session \
    --target "${INSTANCE_ID}" \
    --region "${REGION}" \
    --document-name AWS-StartInteractiveCommand \
    --parameters command="bash -l"