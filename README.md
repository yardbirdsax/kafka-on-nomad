# Apache Kafka on Hashicorp Nomad.

This repository is my record of an attempt to get a secured Apache Kafka cluster running in Docker containers orchestrated by Hashicorp Nomad.

## Pre-Requisites

1. Install [Terraform](https://terraform.io), [Packer](https://packer.io), [Nomad](https://nomadproject.io), and [Consul](https://consul.io). Note that for Nomad and Consul you need only install the binaries, not set up servers.

## Creating a Nomad lab cluster

This repository has a number of sub-modules for creating a complete Nomad cluster setup on various providers using Terraform. If you did not clone the repository using the `--recurse-submodules` option, make sure you run `git submodule update --init` to download everything.

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