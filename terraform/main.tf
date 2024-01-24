resource "helm_release" "kyverno" {
  name             = "kyverno"
  chart            = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  namespace        = "monitoring"
  create_namespace = true

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "admissionController.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "reportsController.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "cleanupController.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "backgroundController.serviceMonitor.enabled"
    value = "true"
  }

  depends_on = [helm_release.kube_prometheus_stack_release]
}

resource "helm_release" "kyverno_polices" {
  name       = "kyverno-policies"
  chart      = "kyverno-policies"
  repository = "https://kyverno.github.io/kyverno/"
  namespace  = "monitoring"
  depends_on = [helm_release.kyverno]
}

resource "helm_release" "kyverno_policies_reporter" {
  name       = "kyverno-policies-reporter"
  chart      = "policy-reporter"
  repository = "https://kyverno.github.io/policy-reporter"
  namespace  = "monitoring"

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "monitoring.enabled"
    value = "true"
  }

  depends_on = [helm_release.kyverno_polices]
}

resource "helm_release" "kube_prometheus_stack_release" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  values           = ["${file("${path.module}/prometheus.values.yaml")}"]

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
}

resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
  }
}

resource "kubernetes_manifest" "resource_policy" {
  manifest   = yamldecode(file("${path.module}/../policies/resource-policy.yaml"))
  depends_on = [helm_release.kyverno_polices]
}

resource "kubernetes_manifest" "pods-label" {
  manifest   = yamldecode(file("${path.module}/../policies/pods-label.yaml"))
  depends_on = [helm_release.kyverno_polices]
}

resource "kubernetes_manifest" "restricted-pod-security" {
  manifest   = yamldecode(file("${path.module}/../policies/restricted-pod-security.yaml"))
  depends_on = [helm_release.kyverno_polices]
}

resource "kubernetes_manifest" "disable-default-namespace" {
  manifest   = yamldecode(file("${path.module}/../policies/disallow-default-namespace.yaml"))
  depends_on = [helm_release.kyverno_polices]
}

resource "kubernetes_manifest" "pull-policy-always" {
  manifest   = yamldecode(file("${path.module}/../policies/pull-policy-always.yaml"))
  depends_on = [helm_release.kyverno_polices]
}

