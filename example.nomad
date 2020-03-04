job "mysql-checker-job" {
  datacenters = ["dc1"]
  priority    = 50

update {
    max_parallel      = 500
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "1m"
    progress_deadline = "30m"
    auto_revert       = false
    auto_promote      = false
    canary            = 0
    stagger           = "10s"
  }

  group "mysql-checker-group" {
    count = 50

    task "mysql-checker-task" {
      vault {
        policies = ["mysql-checker"]
      }
      driver       = "docker"
      kill_timeout = "1m"
      config {
        image = "seatgeek/mysql-checker"
        port_map {
          http = 8080
        }
      }

      template {
        data = <<EOH
{{ with secret "database/creds/checker" }}
MYSQL_USERNAME="{{ .Data.username }}"
MYSQL_PASSWORD="{{ .Data.password }}"
{{ end }}
MYSQL_HOST="mysql.service.consul"
EOH

        destination = "secrets/secrets.env"
        env         = true
      }


      resources {
        cpu    = 20
        memory = 10
        network {
          mbits = 10
          port "http" {}
        }
      }


      service {
        name = "mysql-checker"
        port = "http"
        check {
          name     = "bandrei-mysql-checker"
          type     = "http"
          port     = "http"
          path     = "/healthcheck"
          interval = "5s"
          timeout  = "3s"
          initial_status = "warning"
        }
      }
    }
  }
}
