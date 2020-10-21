job "zookeeper" {
  region = "us-east-1"
  datacenters = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e","us-east-1f"]

  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "zookeeper" {
    count = 3

    constraint {
      operator = "distinct_property"
      attribute = "${node.datacenter}"
      value     = 1
    }

    service {
      name = "zookeeper"
      port = "zk"
      check {
        type = "tcp"
        port = "zk"
        interval = "10s"
        timeout = "1s"
      }
    }

    service {
      name = "zookeeper-discovery1"
      port = "zk_cluster1"
      # check {
      #   type = "tcp"
      #   port = "zk_cluster1"
      #   interval = "10s"
      #   timeout = "15s"
      # }
    }

    service {
      name = "zookeeper-discovery2"
      port = "zk_cluster2"
      check {
        type = "tcp"
        port = "zk_cluster2"
        interval = "10s"
        timeout = "15s"
      }
    }

    network {
      port "zk" {
        static = 2181
      }
      port "zk_cluster1" {
        static = 2888
      }
      port "zk_cluster2" {
        static = 3888
      }
      mode = "host"
    }

    ephemeral_disk {
      migrate = true
      size = "1024"
      sticky = true
    }

    task "zookeeper" {
      driver = "docker"

      config {
        image = "zookeeper:3.5.8"
        ports = [
          "zk",
          "zk_cluster1",
          "zk_cluster2"
        ]
        network_mode = "host"
      }

      template {
        data = <<EOT
ZOO_SERVERS={{ range $index, $element := service "zookeeper-discovery1|any" }}{{ printf "server.%d:%s:%d:%d:participant;0.0.0.0:%d " $index .Address 2888 3888 2181 }}{{ end }}
EOT
        destination = "secrets/file.env"
        env = true
        change_mode = "restart"
      }
      env = {
        ZOO_MY_ID = "${NOMAD_ALLOC_INDEX}"
        ZOO_CFG_EXTRA = "clientPort=${NOMAD_HOST_PORT_zk} quorumListenOnAllIPs=true standaloneEnabled=false initLimit=10 syncLimit=5 4lw.commands.whitelist=stat,ruok,conf,isro"
      }

      resources { 
        memory = 512
      }
    }
  }
}