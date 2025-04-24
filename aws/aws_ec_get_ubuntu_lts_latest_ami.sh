aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*" \
            "Name=virtualization-type,Values=hvm" \
  --region us-west-2 \
  --query "Images[?CreationDate!=\`null\`] | sort_by(@, &CreationDate)[-1].ImageId" \
  --output text