# GitBlox Infrastructure

## Getting Started
- Install terraform [Installation Instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment

>*This example will create the following resources in the specified AWS Region:*

- Configure environment file in `config\ipfs-node\${workspace}.env`
  - See `config\ipfs-node\env.example for required environment variables`
- Configure `terraform.tfvars`
  - See `terraform.tfvars.exmaple for required variables`
  - If not configured terraform will prompt you for required values
- `terraform workspace select $environment` (develop, stage, prod)
- `terraform apply`

Region is configured per workspace and is mapped in `variables.tf`

- Virtual Private Cloud (10.0.0.0/16)
- Internet Gateway
- Route Table
  - Egress all
- Public Subnets (10.0.x.0/24)4
  - One for each availability zone (depending on region)
- Elastic Load Balancer
  - LB https 443->8080 for IPFS Gateway
- Security Group (ELB)
  - Ingress
    - 443 tcp all
  - Egress
    - all all all
- Security Group (ipfs-node)
  - Ingress
    - all  all all - whitelisted IP addresses
    - 8080 tcp ipfs-gateway - ELB
    - 4001 tcp all - p2p
  - Egress
    - all   all all
- Key Pair
- EC2 Instance (Ubuntu Server 20.04.4 LTS)
- Route53 (DNS)
  - `ipfs-${count.index}.${terraform.workspace}.gitblox.io`
    - ex: `ipfs-1.develop.gitblox.io`
    - use for SSH or API access
  - `ipfs-gateway.${terraform.workspace}.gitblox.io`
    - ex: `ipfs-gateway.develop.gitblox.io`
    - use for HTTPS gateway access via ELB
    - [Example Link](https://ipfs-gateway.develop.gitblox.io/ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/readme)

### Connect

 - Run `./connect.sh ipfs_node #` with `#` being `0..n` node index if deploying multiple nodes
 - SSH public key must exist on server under `~/.ssh/authorized_keys`
   - Can be added to `terraform.tfvars` as `ssh_key_1` or `ssh_key_2`
   - More can be added as needed
 - IP address must be included to `terraform.tfvars` as `ip_whitelist`
   - Must be in `address/cidr` format `ip_whitelist = ["x.x.x.x/32"]`