#### Filter
Most list commands support a few common options
```
--filter="zone:VALUE"
--sort-by (NAME, ~NAME)
--uri
 (https://www.googleapis.com/compute/v1/projects/windows-sql-cloud/global/images/sql-2019-web-
windows-2019-dc-v20210112)
```

machine-types 
```bash
gcloud compute instances list --filter zone:europe-west1-c
gcloud compute machine-types list --filter "zone:(europe-west1-c europe-west1-c)"
gcloud compute machine-types list --filter zone:europe-west1-c
gcloud compute machine-types describe e2-highmem-2
```

#### Working with multiple projetcs / configs

create a new config
```bash
gcloud config configurations create picasso
gcloud config configurations list
```

```bash
set default values for new config
gcloud config set project picasso-network 
gcloud config set account radu.p@composable.finance
```

#####  Compute Instances - Default Region and Zone

Option 1 (Centralized Configuration): 
```
gcloud compute project-info add-metadata \
   --metadata=[google-compute-default-region=REGION | google-compute-default-zone=ZONE]
```

Option 2 (Local gcloud configuration):
```
gcloud config set compute/region REGION
```

