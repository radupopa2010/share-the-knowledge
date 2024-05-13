
# Inspired by: https://ioflood.com/blog/jq-select/
# create file containing input object
cat << _EOF_ > out.json 
{
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0dbf84f9b7080dbee",
            "GroupId": "sg-024e2bd88342dbdcd",
            "GroupOwnerId": "052940064682",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 5432,
            "ToPort": 5432,
            "ReferencedGroupInfo": {
                "GroupId": "sg-0618518a7bedf3f2e",
                "UserId": "052940064682"
            },
            "Tags": []
        },
        {
            "SecurityGroupRuleId": "sgr-0aabf50c5029b455e",
            "GroupId": "sg-024e2bd88342dbdcd",
            "GroupOwnerId": "052940064682",
            "IsEgress": true,
            "IpProtocol": "-1",
            "FromPort": -1,
            "ToPort": -1,
            "CidrIpv4": "0.0.0.0/0",
            "Tags": []
        }
    ]
}
_EOF_

jq '.SecurityGroupRules[] | select(.FromPort == 5432)' out.json
{
  "SecurityGroupRuleId": "sgr-0dbf84f9b7080dbee",
  "GroupId": "sg-024e2bd88342dbdcd",
  "GroupOwnerId": "052940064682",
  "IsEgress": false,
  "IpProtocol": "tcp",
  "FromPort": 5432,
  "ToPort": 5432,
  "ReferencedGroupInfo": {
    "GroupId": "sg-0618518a7bedf3f2e",
    "UserId": "052940064682"
  },
  "Tags": []
}