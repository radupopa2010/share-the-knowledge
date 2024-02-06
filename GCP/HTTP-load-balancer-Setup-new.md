# Set up an HTTP load balancer
HTTP(S) Load Balancing is implemented on Google Front End (GFE). GFEs are 
distributed globally and operate together using Google's global network and 
control plane. You can configure URL rules to route some URLs to one set of 
instances and route other URLs to other instances.

Requests are always routed to the instance group that is closest to the user, 
if that group has enough capacity and is appropriate for the request. 
If the closest group does not have enough capacity, the request is sent to the 
closest group that does have capacity.

To set up a load balancer with a Compute Engine backend, your VMs need to be 
in an instance group. The managed instance group provides VMs running the 
backend servers of an external HTTP load balancer.

[1. Create an instance template](#Create-an-instance-template)

[2. Create a managed instance group.](#Create-a-managed-instance-group.)

[3. Create a firewall rule to allow traffic on TCP port 80.](#Create-a-firewall-rule-to-allow-traffic-on-TCP-port-80.)

[4. Set up a global static external IP address that your customers use to reach your load balancer](#Set-up-a-global-static-external-IP-address-that-your-customers-use-to-reach-your-load-balancer)

[5. Create a health check.](#Create-a-health-check.)

[6. Create a backend service, and attach the managed instance group with named port http 80.](#Create-a-backend-service,-and-attach-the-managed-instance-group-with-named-port-http-80.)

[7. Create an URL Map to route the incoming requests to the default backend service.](#URL-Map)

[8. Create a target HTTP proxy to route requests to your URL map.](#Create-a-target-HTTP-proxy-to-route-requests-to-your-URL-map.)

[9. Create a forwarding rule.](#Create-a-forwarding-rule.)


## 1. Create an instance template  <a name="Create-an-instance-template"></a>

It is important to
  - specify a network and subnetwork
  - add networking tags, requied when creating firewall rules

```bash
# Create a startup script
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

# Create instance tempalte with startup script
INSTANCE_TEMPLATE=nginx-server-nucleus
STARTUP_SH=startup.sh
REGION=us-west4
MACHINE_TYPE=n1-standard-1
NETWORK_TAGS=allow-health-check

gcloud compute instance-templates create "${INSTANCE_TEMPLATE}" \
       --metadata-from-file startup-script="${STARTUP_SH}" \
       --region="${REGION}" \
       --machine-type="${MACHINE_TYPE}" \
       --network=default \
       --subnet=default \
       --tags="${NETWORK_TAGS}" \
       --image-family=debian-11 \
       --image-project=debian-cloud
```

## 2. Create a managed instance group. <a name="Create-a-managed-instance-group."></a>
Managed instance groups (MIGs) let you operate apps on multiple identical VMs. 
You can make your workloads scalable and highly available by taking advantage 
of automated MIG services, including: autoscaling, autohealing, regional 
(multiple zone) deployment, and automatic updating.

```bash
MANAGED_INSTANCE_GROUP=ngix-instance-gr-nucleus
INSTANCE_TEMPLATE=nginx-server-nucleus
SIZE=2
ZONE=us-west4-c

gcloud compute instance-groups managed create "${MANAGED_INSTANCE_GROUP}" \
       --template="${INSTANCE_TEMPLATE}" \
       --size="${SIZE}" \
       --zone="${ZONE}"
```

## 3. Create a firewall rule to allow traffic on TCP port 80. <a name="Create-a-firewall-rule-to-allow-traffic-on-TCP-port-80."></a>
The ingress rule allows traffic from the Google Cloud health checking systems (`130.211.0.0/22` and `35.191.0.0/16`).

```bash
FW_RULE=allow-tcp-rule-235
NETWORK_TAGS=allow-health-check

gcloud compute firewall-rules create "${FW_RULE}" \
  --network=default \
  --action=allow \
  --target-tags="${NETWORK_TAGS}"  \
  --rules=tcp:80

#  --direction=ingress \
#  --source-ranges=130.211.0.0/22,35.191.0.0/16 \

# Test that the rules work
gcloud compute instances list
curl http://[IP_ADDRESS]
```

## 4. Set up a global static external IP address that your customers use to reach your load balancer. <a name="Set-up-a-global-static-external-IP-address-that-your-customers-use-to-reach-your-load-balancer"></a>

```bash
GLOBAL_IP=nucleus-lb-ip
gcloud compute addresses create "${GLOBAL_IP}" \
       --ip-version=IPV4 \
       --global
```

## 5. Create a health check. <a name="Create-a-health-check."></a>

```bash
CHECK=http-basic-check

gcloud compute health-checks create http "${CHECK}" \
       --port 80
```

## 6. Create a backend service, and attach the managed instance group with named port http 80. <a name="Create-a-backend-service,-and-attach-the-managed-instance-group-with-named-port-http-80."></a>

```bash
# Create the baclend-service
BACKEND_SVC=nginx-server-nucleus

gcloud compute backend-services create "${BACKEND_SVC}" \
       --protocol=HTTP \
       --port-name=http \
       --health-checks="${CHECK}" \
       --global

# Add instance group as the backend to the backend-service:
gcloud compute backend-services add-backend "${BACKEND_SVC}" \
       --instance-group="${MANAGED_INSTANCE_GROUP}" \
       --instance-group-zone="${ZONE}" \
       --global
```

## 7. Create an URL Map to route the incoming requests to the default backend service and a HTTP Proxy to route requests to your URL map.<a name="URL-Map"></a>

URL map is a Google Cloud configuration resource used to route requests 
to backend services or backend buckets. For example, with an external HTTP(S) 
load balancer, you can use a single URL map to route requests to different 
destinations based on the rules configured in the URL map:
  - Requests for https://example.com/video go to one backend service.
  - Requests for https://example.com/audio go to a different backend service.
  - Requests for https://example.com/images go to a Cloud Storage backend bucket.
Requests for any other host and path combination go to a default backend service.

```bash
URL_MAP=web-map-http-nucleus

gcloud compute url-maps create "${URL_MAP}" \
       --default-service "${BACKEND_SVC}"
```

## 8. Create a target HTTP proxy to route requests to your URL map: <a name="Create-a-target-HTTP-proxy-to-route-requests-to-your-URL-map."></a>
```bash
HTTP_PROXY=http-lb-proxy

gcloud compute target-http-proxies create "${HTTP_PROXY}" \
       --url-map "${URL_MAP}"
```

## 9. Create a forwarding rule. <a name="Create-a-forwarding-rule."></a>
A forwarding rule and its corresponding IP address represent the frontend 
configuration of a Google Cloud load balancer. 

```bash
FORWARDING_RULE=http-content-rule-nucleus

gcloud compute forwarding-rules create "${FORWARDING_RULE}" \
       --address="${GLOBAL_IP}"\
       --global \
       --target-http-proxy="${HTTP_PROXY}" \
       --ports=80
```
