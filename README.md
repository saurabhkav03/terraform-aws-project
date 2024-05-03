# Terraform AWS Infrastructure Deployment

## Prerequisites

Before you begin, make sure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/install)
    - Installation guide: [Terraform Installation](https://developer.hashicorp.com/terraform/install)

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - Installation guide: [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Additionally, ensure you have AWS access keys configured by running the following command and providing your access key, secret key, preferred region, and output format:


## Project Structure

1. **Provider Configuration**: 
    - Create a file named `provider.tf` to define the platform Terraform is trying to connect to. 
    - Refer to the [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for detailed information on how to configure the AWS provider.

2. **Initialization**: 
    - Run `terraform init` to initialize Terraform and verify connectivity with AWS. 
    - Initialization is the first step to verify if you are connected to AWS using Terraform.

3. **Main Configuration**: 
    - Create `main.tf` and `variables.tf` to define the infrastructure.
    - Refer to the AWS UI and documentation for better understanding and customization.

    - For `main.tf`:
        - [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc): Configure VPC settings.
        - [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet): Create two subnets and specify public IP to the subnet.
        - [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway): Attach an internet gateway.
        - [Route Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table): Allow all the traffic inside VPC to reach the internet gateway.
        - [Route Table Association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association): Attach the route table to both public subnets.

    - For `variables.tf`:
        - Refer to the [Terraform AWS Variables](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-variables) guide for information on defining variables.

4. **Load Balancer Setup**:
    - Create an Application Load Balancer (ALB) using the [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) resource.
    - Associate both subnets to the load balancer.
    - Configure a [Target Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) to route requests to EC2 instances.
    - Attach instances to the target group using the [lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) resource.
    - Attach the load balancer to the target group using the [lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) resource.

## Scripting

- Create two scripts to verify load balancing and add one to each EC2 instance. 
- Refer to the [AWS Instance Metadata Retrieval](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html) guide for information on retrieving instance metadata.

Ensure to refer to the [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and AWS UI for better understanding and customization.

