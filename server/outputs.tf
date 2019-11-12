output "service_name" {
  value = kubernetes_service.server.metadata[0].name
}
