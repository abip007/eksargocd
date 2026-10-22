# ---------- General ----------
variable "region" {
  description = "AWS region for everything."
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile Terraform (and kubectl/helm auth) should use, e.g. \"abip007\". Never use root keys. null = default credential chain."
  type        = string
  default     = "abip007home"
}

variable "cluster_name" {
  description = "EKS cluster name. Every IAM role/policy name is prefixed with it, so several clusters can share one account."
  type        = string
  default     = "prod-eks"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version."
  type        = string
  default     = "1.36"
}

variable "tags" {
  description = "Tags added to every AWS resource."
  type        = map(string)
  default = {
    "managed-by" = "terraform"
    "project"    = "eks-platform"
  }
}

# ---------- Network (Step 1) ----------
variable "vpc_cidr" {
  description = "VPC CIDR. Public /20 and private /19 subnets are carved from it across 3 AZs."
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "true = one NAT gateway (cheap, lab). false = one per AZ (production HA)."
  type        = bool
  default     = true
}

# ---------- Cluster (Step 2) ----------
variable "api_public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API endpoint. Restrict to your office/home IP, e.g. [\"203.0.113.10/32\"]."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "Control-plane log types sent to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

# ---------- Nodes (Step 3) ----------
variable "node_instance_types" {
  description = "Instance types for the managed node group. t3.large holds 35 pods; t3.small only 11 (the 'Too many pods' issue)."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Root volume size per node (GiB)."
  type        = number
  default     = 50
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  description = "Initial size only. Cluster Autoscaler changes it afterwards, so Terraform ignores later drift."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Upper limit Cluster Autoscaler may scale to ('max node group size reached' if too low)."
  type        = number
  default     = 3
}

# ---------- User access (Step 4) ----------
variable "human_role_trusted_arns" {
  description = "IAM users/roles allowed to assume the admin/developer/viewer roles. Empty = any IAM user in this account that has sts:AssumeRole permission."
  type        = list(string)
  default     = []
}

variable "require_mfa_for_human_roles" {
  description = "Require MFA to assume the admin/developer/viewer roles (then the CLI profile needs mfa_serial)."
  type        = bool
  default     = false
}

variable "developer_namespaces" {
  description = "Namespaces the developer role may edit. They are created by Terraform."
  type        = list(string)
  default     = ["apps", "three-tier"]
}

variable "additional_admin_principal_arns" {
  description = "Extra IAM users/roles given cluster-admin directly. Do NOT include the identity running Terraform; it already gets admin as cluster creator."
  type        = list(string)
  default     = []
}

# ---------- Controllers (Steps 5-7) ----------
variable "cluster_autoscaler_image_tag" {
  description = "Match the Kubernetes minor version (1.36 -> v1.36.x)."
  type        = string
  default     = "v1.36.1"
}

variable "cluster_autoscaler_chart_version" {
  description = "Helm chart version; null = latest."
  type        = string
  default     = null
}

variable "aws_lbc_version" {
  description = "AWS Load Balancer Controller release whose gateway CRDs are installed (IAM policy in policies/ matches v3.6.0)."
  type        = string
  default     = "v3.6.0"
}

variable "aws_lbc_chart_version" {
  description = "aws-load-balancer-controller Helm chart version; null = latest."
  type        = string
  default     = null
}

variable "gateway_api_version" {
  description = "Kubernetes Gateway API CRD release (LBC v3.5+ needs v1.6.0)."
  type        = string
  default     = "v1.6.0"
}

variable "cert_manager_chart_version" {
  description = "cert-manager chart version, e.g. \"v1.21.0\"; null = latest."
  type        = string
  default     = null
}

# ---------- TLS (Step 7) ----------
variable "domain_name" {
  description = "Public Route 53 hosted zone in this account, e.g. \"bestclick.click\". Empty = skip ACM certificate."
  type        = string
  default     = ""
}

variable "letsencrypt_email" {
  description = "Real email for Let's Encrypt (example.com is rejected). Empty = skip ClusterIssuers."
  type        = string
  default     = ""
}

# ---------- Storage (Step 8) ----------
variable "enable_efs" {
  description = "Also create an EFS file system + EFS CSI driver + 'efs' StorageClass (ReadWriteMany)."
  type        = bool
  default     = false
}

# ---------- Security / apps (Step 10) ----------
variable "enable_network_policy" {
  description = "Turn on Kubernetes NetworkPolicy enforcement in the VPC CNI."
  type        = bool
  default     = true
}

variable "ecr_repositories" {
  description = "ECR repositories to create (the 3-tier Notes app images by default). Empty list = none."
  type        = list(string)
  default     = ["notes-api", "notes-frontend"]
}

variable "ecr_force_delete" {
  description = "Allow 'terraform destroy' to delete ECR repositories that still contain images."
  type        = bool
  default     = true
}
