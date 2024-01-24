variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "grafana_admin_password" {
  type      = string
  default   = "admin"
  sensitive = true
}
