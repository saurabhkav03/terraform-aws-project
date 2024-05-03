#for vpc
resource "aws_vpc" "main_vpc" {

    cidr_block = "10.0.0.0/16"
}

# Creating 2 subnets with public ip enabled
resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-1c"

  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1b"

  map_public_ip_on_launch = true
}

#internet gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main_vpc.id
}

#route table to allow flow of traffic inside subnets
resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.main_vpc.id
#you are essentially allowing all traffic from within the VPC to reach the internet gateway. This means that any instance or resource within the VPC can send traffic to destinations outside the VPC, such as the internet or other external networks, via the specified internet gateway.
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
}

#in route table destination is internet gateway and now we will attach it to both public subnet
resource "aws_route_table_association" "route1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "route2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.route_table.id
}

#create security group for both ec2 and load balancer
resource "aws_security_group" "allow_http_ssh" {
    name = "allow_http_ssh"
    description = "Allow HTTP and SSH inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.main_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
    security_group_id = aws_security_group.allow_http_ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
    security_group_id = aws_security_group.allow_http_ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
    security_group_id = aws_security_group.allow_http_ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

#create s3 bucket
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "saurabh-demo-3may-2024"
}

#create ec2 instance
resource "aws_instance" "webserver1" {
  ami           = "ami-036cafe742923b3d9"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file("data1.sh"))
}

resource "aws_instance" "webserver2" {
  ami           = "ami-036cafe742923b3d9"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file("data2.sh"))
}

#create alb
resource "aws_lb" "demo-lb" {
  name               = "demo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
#  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

#instance target group to attach instance with target group
resource "aws_lb_target_group" "target_group" {
  name     = "test-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#Now attach instance with target group
resource "aws_lb_target_group_attachment" "target_group_attach1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target_group_attach2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

#Instances are attached but still need to attach load balancer to target group for this we will use lb listener
resource "aws_lb_listener" "lb_listen" {
  load_balancer_arn = aws_lb.demo-lb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

output "loadbalancer" {
  value = aws_lb.demo-lb.dns_name  
}