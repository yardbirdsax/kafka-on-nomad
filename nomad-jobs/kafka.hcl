job "kafka" {
  region = "us-east-1"
  datacenters = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e","us-east-1f"]

  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "kafka" {
    count = 3

    constraint {
      operator = "distinct_property"
      attribute = "${node.datacenter}"
      value     = 1
    }

    service {
      name = "kafka-plain"
      port = "kafka_plain"
      check {
        type = "tcp"
        port = "kafka_plain"
        interval = "10s"
        timeout = "1s"
      }
    }

    network {
      port "kafka_plain" {
        static = 9092
      }
      mode = "host"
    }

    ephemeral_disk {
      migrate = true
      size = "1024"
      sticky = true
    }

    task "kafka" {
      driver = "docker"

      config {
        image = "bitnami/kafka:2.6.0"
        ports = [
          "kafka_plain"
        ]
        network_mode = "host"
      }

      template {
        data = <<EOT
KAFKA_CFG_ZOOKEEPER_CONNECT={{ range $index, $element := service "zookeeper|any" }}{{ printf "%s:%d," .Address 2181 }}{{ end }}
EOT
        destination = "secrets/file.env"
        env = true
        change_mode = "restart"
      }

      env {
        ALLOW_PLAINTEXT_LISTENER = "yes"
        KAFKA_HEAP_OPTS = "-Xmx512M -Xms512M"
      }

      resources { 
        memory = 512
      }
    }
  }
}