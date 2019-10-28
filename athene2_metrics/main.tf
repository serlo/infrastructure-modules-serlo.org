resource "google_logging_metric" "logging_metric_httpd_200" {
  name   = "athene2-httpd-container-200/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=athene2-httpd-container AND jsonPayload.status=200"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "logging_metric_httpd_404" {
  name   = "athene2-httpd-container-404/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=athene2-httpd-container AND jsonPayload.status=404"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "logging_metric_httpd_401" {
  name   = "athene2-httpd-container-401/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=athene2-httpd-container AND jsonPayload.status=401"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "logging_metric_httpd_403" {
  name   = "athene2-httpd-container-403/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=athene2-httpd-container AND jsonPayload.status=403"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "logging_metric_httpd_5xx" {
  name   = "athene2-httpd-container-5xx/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=athene2-httpd-container AND jsonPayload.status=500 OR jsonPayload.status=502 OR jsonPayload.status=503"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "logging_metric_httpd_responsetime" {
  name   = "athene2-httpd-container-responsetime/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=athene2-httpd-container AND jsonPayload.response_time > 0"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "DISTRIBUTION"
  }
  value_extractor = "EXTRACT(jsonPayload.response_time)"
  bucket_options {
    linear_buckets {
      num_finite_buckets = 5
      width              = 250
      offset             = 0
    }
  }
}

resource "google_logging_metric" "logging_metric_dbdump_success" {
  name   = "athene2-dbdump-success/metric"
  filter = "resource.type=k8s_container AND resource.labels.container_name=dbdump-container AND jsonPayload.message=\"dump of serlo database - end\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

provider "google" {
  version = "~> 2.18"
}
