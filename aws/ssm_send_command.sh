aws ssm send-command \
    --instance-ids "i-0a782d3bd7ae4ad5c" \
    --region us-east-1 \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["grep -i rev /etc/systemd/system/suzuka-full-node.service"]'

aws ssm list-command-invocations \
    --command-id "0c02ff96-7d6f-423e-ab95-db11d2f1a583" \
    --details \
    --region us-east-1
