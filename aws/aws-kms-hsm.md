# AWS Key Management Service


## Key policies

https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html

- IAM best practices discourage the use of IAM users with long-term credentials.
Whenever possible, use IAM roles, which provide temporary credentials. For
details, see Security best practices in IAM in the IAM User Guide.

- If the required Resource element is missing from a key policy statement, the 
policy statement has no effect. A key policy statement without a Resource 
element doesn't apply to any KMS key.

When a key policy statement is missing its Resource element, the AWS KMS console correctly reports an error, but the CreateKey and PutKeyPolicy APIs succeed, even though the policy statement is ineffective.

- [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)