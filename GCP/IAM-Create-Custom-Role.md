https://cloud.google.com/iam/docs/creating-custom-roles

Custom roles at project level and at organization level

### How to create custom role to grant access to user to ssh into a VM


Go to IAM -> Roles -> Create Role


How to test what permissions you need?
- Authenticate with another account that you own and that has no permissions
```bash
gcloud auth login radupopa21@gmail.com
```

- try running commands that will tell you which permissions are missing

```
gcloud compute ssh redis-jumper \
       --project biconomy-prod  \
       --zone=us-east1-b -- -N -L 6379:10.78.17.84:6379
ERROR: (gcloud.compute.ssh) Could not fetch resource:
 - Required 'compute.instances.get' permission for 'projects/biconomy-prod/zones/us-east1-b/instances/redis-jumper'

```

- via the console add `compute.instances.get` this to the new custom role

- Repeat running the same command until you have added all the required permissions

- Unassigned the role form your custom role