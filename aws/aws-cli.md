### How to authenticate aws cli with short lived tokens

1. You need to enable and configure IAM Identity Center directory. <br>


Follow this guide https://docs.aws.amazon.com/singlesignon/latest/userguide/quick-start-default-idc.html
<br>
- Enable  IAM Identity Center for AWS organisation.
- Create IAM Identity Center group.
- Add user to group.
- Add Permissions to "Admin team" group.


2. [Configure the AWS CLI to use IAM Identity Center token provider credentials 
with automatic authentication refresh](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html)

`SSO start URL` -> IAM Identity Center Dashboard -> AWS access portal URL

e.g. `https://d-RANDMON_REMOVED.awsapps.com/start`

```
aws configure sso
SSO session name (Recommended): my-sso
SSO start URL [None]: https://my-sso-portal.awsapps.com/start
SSO region [None]: us-east-2
SSO registration scopes [None]: sso:account:access
```
<br>
https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-manual
or edit  `.aws/config`

```
[default]
region = us-east-2
# To use a named profile for multiple commands, you can avoid specifying the 
# profile in every command by setting the AWS_PROFILE environment variable as 
# the default profile
# profile = radupopa    --> this will not work
output = text
sso_session = my-sso

[profile my-dev-profile]
sso_session = my-sso
sso_account_id = 123456789011
sso_role_name = readOnly
region = us-west-2

[sso-session my-sso]
sso_region = us-east-1
sso_start_url = https://my-sso-portal.awsapps.com/start
sso_registration_scopes = sso:account:access
```

test connection with

```bash
aws s3 ls --profile my-dev-profile
```

```bash
aws sso login
# go through the worklow
```

if ssm is configured, use it to connect to the instance
```bash
aws ssm start-session --target i-instance-id123 --region us-east-1
aws ssm start-session \
     --target i-02864ba14bbe88154 \
     --document-name AWS-StartInteractiveCommand \
     --parameters command="bash -l" \
     --region us-east-1
```


###### Get info about the account that is logged in
```
aws iam list-account-aliases
```
```
{
    "AccountAliases": [
        "radugp"
    ]
}
```


###### List ec2 instance

```bash
aws ec2 describe-instances --region us-east-2 --profile radupopa
```


```
aws ec2 describe-instances --region us-east-2 --profile radupopa  | jq '.Reservations.[].Instances.[].Tags.[].Value'
```

###### How to use the query to select onnly desired fields

```
aws ec2 describe-regions --query "Regions[].RegionName" --output json
```

Regular output (without --query) would look like this
```
aws ec2 describe-regions  --output json
{
    "Regions": [
        {
            "Endpoint": "ec2.ap-south-1.amazonaws.com",
            "RegionName": "ap-south-1",
            "OptInStatus": "opt-in-not-required"
        },
        {
            "Endpoint": "ec2.eu-north-1.amazonaws.com",
            "RegionName": "eu-north-1",
            "OptInStatus": "opt-in-not-required"
        }
    ]
}
```

and with `--query`

```
aws ec2 describe-regions --query "Regions[].RegionName" --output json
[
    "ap-south-1",
    "eu-north-1"
]
```
<br>

```
aws ec2 describe-regions --query "Regions[].RegionName" --output text

ap-south-1      eu-north-1
```
