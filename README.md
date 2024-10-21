# mk8s example of using load-balancer


This repository contains a small example of creating a managed k8s cluster in Nebius with an example deployement leveraging `load-balancer`.

## Setting up `load-balancer`

In Nebius, there's no dedicated API available to create `load-balancer` (LB) service. Instead, you should use [terraform k8s provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs). There are 2 types of LB available:
- Internal
- Public with IPv4

This is managed through annotation:
- `nebius.com/load-balancer-allocation-id` - specify allocation to use with load-balancer

- `nebius.com/load-balancer-type: "internal"` - specify that private allocation is used with load-balancer

Please note that the default LB type is external. Thus if `nebius.com/load-balancer-type: "internal"` is not set, the platform will create an external `load-balancer`.

Possible options:

- `nebius.ai/load-balancer-type: "internal"` is set but `nebius.ai/load-balancer-allocation-id` is not - will create private ipv4 allocation.

- `nebius.ai/load-balancer-type: "internal"` and `nebius.ai/load-balancer-allocation-id` are both set - will validate that the provided allocation is private.

- `nebius.ai/load-balancer-type` is not set but `nebius.ai/load-balancer-allocation-id` is set - will validate that the provided allocation is public.

- neither `nebius.ai/load-balancer-type` nor `nebius.ai/load-balancer-allocation-id` is set - will create public ipv4 allocation.

See `deployement.tf` for reference. In this example, default configuration is used (it creates a public IPv4 allocation for the `load-balancer`)

## Prerequisites

1. Install [Nebius CLI](https://docs.nebius.ai/cli/install/):
   ```bash
   curl -sSL https://storage.ai.nebius.cloud/nebius/install.sh | bash
   ```

2. Reload your shell session:

   ```bash
   exec -l $SHELL
   ```

   or

   ```bash
   source ~/.bashrc
   ```

3. [Configure](https://docs.nebius.ai/cli/configure/) Nebius CLI (it's recommended to
   use [service account](https://docs.nebius.ai/iam/service-accounts/manage/) for configuration):
   ```bash
   nebius init
   ```

4. Install JQuery (example for Debian-based distros):
   ```bash
   sudo apt install jq -y
   ```

## Usage

1. Load environment variables:
   ```bash
   source ./environment.sh
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Provide necessary variables in `terraform.tfvars`
    ```
    # Cloud environment and network
    parent_id      = "<your-project-id>"
    subnet_id      = "<your-vpc-subnet-id>"       
    ```
4. Preview the deployment plan:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```
   Wait for the operation to complete.

## Trying it out

After `terraform apply` is done, you will get something like that in your terminal:
```
Outputs:

load_balancer_ip = "<lb-public-IP>"
```

You may check if the `service` is correctly created:
```
➜  ~ kubectl -n=example-namespace get svc nginx 
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nginx   LoadBalancer   <cluster-IP>     <lb-public-IP>   80:30615/TCP   2m
```
To test if `load-balancer` is working, do the following:
```
curl <lb-public-IP>
```
You should get different host names in return:
```
➜  ~ curl <lb-public-IP>
nginx-deployment-766f4b5845-87st6
➜  ~ curl <lb-public-IP>
nginx-deployment-766f4b5845-psjk2
```