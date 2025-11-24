################################
# Namespace
################################
resource "kubernetes_namespace" "notes" {
  metadata {
    name = "notes"
  }
}

################################
# DATABASE
################################
resource "kubernetes_deployment" "db" {
  metadata {
    name      = "notes-db"
    namespace = kubernetes_namespace.notes.metadata[0].name
    labels = {
      app = "notes-db"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-db"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-db"
        }
      }

      spec {
        container {
          name  = "notes-db"
          image = "postgres:15"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "notes"
          }

          env {
            name  = "POSTGRES_USER"
            value = "notes"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "notes"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "db" {
  metadata {
    name      = "notes-db"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-db"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}

################################
# API
################################
resource "kubernetes_deployment" "api" {
  wait_for_rollout = false

  metadata {
    name      = "notes-api"
    namespace = kubernetes_namespace.notes.metadata[0].name
    labels = {
      app = "notes-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-api"
        }
      }

      spec {
        container {
          name  = "notes-api"
          image = "notes-api:1.0"

          port {
            container_port = 3000
          }

          env {
            name  = "DB_HOST"
            value = kubernetes_service.db.metadata[0].name
          }

          env {
            name  = "DB_PORT"
            value = "5432"
          }

          env {
            name  = "DB_USER"
            value = "notes"
          }

          env {
            name  = "DB_PASSWORD"
            value = "notes"
          }

          env {
            name  = "DB_NAME"
            value = "notes"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = "notes-api"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-api"
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

################################
# FRONTEND
################################
resource "kubernetes_deployment" "frontend" {
  wait_for_rollout = false

  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notes.metadata[0].name
    labels = {
      app = "notes-frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-frontend"
        }
      }

      spec {
        container {
          name  = "notes-frontend"
          image = "notes-frontend:1.0"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-frontend"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

################################
# INGRESS
################################
resource "kubernetes_ingress_v1" "notes_ingress" {
  metadata {
    name      = "notes-ingress"
    namespace = kubernetes_namespace.notes.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
