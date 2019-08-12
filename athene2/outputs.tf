#####################################################################
# outputs for module athene2
#####################################################################

output "athene2_service_ip" {
  value = kubernetes_service.athene2_service.spec.0.cluster_ip
}
