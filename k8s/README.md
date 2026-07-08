# Ingress Controller Setup (one-time, per cluster)

The Helm chart in `helm/agritech-marketplace/` creates an `Ingress` resource,
but it assumes an NGINX Ingress Controller is already running in the cluster.
Install it once per EKS cluster with:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

Wait for the Load Balancer's external DNS name:

```bash
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

Copy the `EXTERNAL-IP` (a DNS name on AWS, e.g.
`a1b2c3d4e5f6.elb.ap-south-1.amazonaws.com`) and use it as
`load_balancer_dns_name` in `terraform/envs/prod/terraform.tfvars` so
Route 53 can point your domain at it.
