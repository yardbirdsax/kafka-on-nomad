# Apache Kafka on Hashicorp Nomad.

This repository is my record of an attempt to get a secured Apache Kafka cluster running in Docker containers orchestrated by Hashicorp Nomad.

## Pre-Requisites

1. Install [Terraform](https://terraform.io), [Packer](https://packer.io), [Nomad](https://nomadproject.io), and [Consul](https://consul.io). Note that for Nomad and Consul you need only install the binaries, not set up servers.

## Creating a Nomad lab cluster

This repository will have a number of sub-modules for creating a complete Nomad cluster setup on various providers using Terraform. If you did not clone the repository using the `--recurse-submodules` option, make sure you run `git submodule update --init` to download everything.

### AWS

Follow these steps to deploy a Nomad cluster on AWS. This assumes you have a valid AWS CLI profile already configured.

1. Navigate in a command prompt to the `nomad-lab/aws` directory in the repository.
1. Run the following commands:
   ```bash
   export AWS_REGION=us-east-1
   terraform init
   terraform plan -out out.tfplan -var-file ../lab.tfvars
   terraform apply out.tfplan
   ```
1. Run the `examples/nomad-examples-helper/nomad-examples-helpers.sh` script to output useful information, such as the IP address of the Nomad master server.
1. Set the following two environment variables to allow your local Nomad and Consul clients to reach the provisioned server(s).

   ```bash
   export CONSUL_HTTP_ADDR=http://<ip>:8500
   export NOMAD_ADDR=http://<ip>:4646
   ```

   >**Ensure you replace the placeholder `<ip>` with the actual IP address shown by the script in the step above.**

## Configuring Consul Services

Since Consul is acting as our source of truth for where Kafka and Zookeeper will be installed, we need to create some static entries there that point to our instances.

1. Navigate to the `kafka-cluster` directory in the repository.
1. Set the following environment variable to the same value as you set for the AWS_REGION variable in the previous section.
   ```
   export TF_VAR_aws_region=us-east-1
