#####################################################################
# outputs for module editor-renderer
#####################################################################
output "cluster_ip" {
  value     = kubernetes_service.editor-renderer_service.spec[0].cluster_ip
  sensitive = true
}


output "service_uri" {
  value     = "http://${kubernetes_service.editor-renderer_service.spec[0].cluster_ip}:${kubernetes_service.editor-renderer_service.spec[0].port[0].port}"
  sensitive = true
}


