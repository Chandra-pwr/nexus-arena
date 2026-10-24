data "aws_eks_cluster" "c" { name = "nexus-dev" }
data "aws_eks_cluster_auth" "c" { name = "nexus-dev" }
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.c.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.c.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.c.token
  }
}
resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
}
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "crds.enabled"
    value = "true"
  }
}
