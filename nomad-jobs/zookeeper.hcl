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
      check {
        type = "tcp"
        port = "zk"
        interval = "10s"
        timeout = "1s"
      }
    }

    network {
      port "zk" {
        static = 2181
      }
    }

    task "zookeeper" {
      driver = "docker"

      config {
        image = "zookeeper:3.6.1"
        ports = [
          "zk"
        ]
      }


    }
  }
}