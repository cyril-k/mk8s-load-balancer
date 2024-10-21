# Kubernetes Namespace
resource "kubernetes_namespace" "example" {
  metadata {
    name = "example-namespace"
  }
}

# Nginx ConfigMap
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name = "nginx-config"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    "nginx.conf" = <<EOF
    events { }

    http {
      server {
        listen 80;
        location / {
          default_type text/plain;
          return 200 "$hostname\n";
        }
      }
    }
    EOF
  }
}


# Kubernetes Deployment for two pods
resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name = "nginx-deployment"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          # Mount the ConfigMap
          volume_mount {
            name       = "nginx-config-volume"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }

          port {
            container_port = 80
          }
        }
        volume {
          name = "nginx-config-volume"

          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Kubernetes Service of type LoadBalancer
resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "nginx"
    namespace = kubernetes_namespace.example.metadata[0].name
    # annotations = {
    #     "nebius.com/load-balancer-type" : "internal",
    # }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

