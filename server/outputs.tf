output "service_name" {
  value = kubernetes_service.server.spec[0].cluster_ip
}
