module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  name                               = "myapp-eks-cluster"
  kubernetes_version                 = "1.35"
  endpoint_public_access                    = true
  enable_cluster_creator_admin_permissions  = true

  vpc_id     = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  tags = {
    environment = "dev"
    application = "myapp"
  }

  addons = {
    vpc-cni = {
      before_compute = true
    }
    kube-proxy = {}
    coredns    = {}
    eks-pod-identity-agent = {}
  }

  eks_managed_node_groups = {
    dev_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.small"]

    }
  }
}
