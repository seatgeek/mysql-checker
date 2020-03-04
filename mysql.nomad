job "mysql-server-job" {
  datacenters = ["dc1"]
  priority    = 50

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "1m"
    progress_deadline = "30m"
    auto_revert       = false
    auto_promote      = false
    canary            = 0
    stagger           = "10s"
  }

  group "mysql-server-group" {
    count = 1

    task "mysql-server-task" {
      driver       = "docker"
      kill_timeout = "1m"

      config {
        image = "mysql"

        port_map {
          mysql = 3308
        }
      }

      env {
        MYSQL_ROOT_PASSWORD = "hackme"
      }

      resources {
        cpu    = 500
        memory = 1000

        network {
          mbits = 10

          port "mysql" {
            static = "3306"
          }
        }
      }

      service {
        name = "mysql-server"
        port = "mysql"

        check {
          name           = "mysql-server"
          type           = "tcp"
          port           = "mysql"
          interval       = "5s"
          timeout        = "3s"
          initial_status = "warning"
        }
      }
    }
  }
}
