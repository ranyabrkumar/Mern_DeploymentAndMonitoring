terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket = "rbrk-b11-monitoring"
    key    = "terraform/state/monitoring/cluster.tfstate"
    region = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_accesskey
  secret_key = var.aws_secretkey
}

#########################
# Key Pair
#########################
resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/Severless_rbrk.pub")
}

#########################
# Networking (VPC, Subnet, IGW, Route Table)
#########################
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ec2_web_sg" {
  name        = "mern-ec2-sg"
  description = "Allow SSH, HTTP,https and App Ports"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Prometheus Node Exporter Port
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Grafana Port
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mern-web-sg" }
}

resource "aws_security_group" "db_sg" {
  name        = "mern-db-sg"
  description = "Allow MongoDB access only from Web SG"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Allow MongoDB from web instances"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec2_web_sg.id]  # Only web_sg can access
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9216
    to_port     = 9216
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mern-db-sg" }
}

# Fetch the first available subnet in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default_subnet" {
  id = data.aws_subnets.default.ids[0]
}


#########################
# IAM Roles for Monitoring and Logging
#########################

# -----------------------------
# IAM Role for EC2 (Monitoring + CloudWatch Access)
# -----------------------------
resource "aws_iam_role" "ec2_monitoring_role" {
  name = "${var.project_name}-ec2-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-monitoring-role"
  }
}

# -----------------------------
# Attach Policies for CloudWatch & SSM
# -----------------------------
# AmazonCloudWatchAgentServerPolicy → Allows pushing metrics/logs to CloudWatch
# AmazonSSMManagedInstanceCore → Enables SSM Session Manager (no SSH needed)
# CloudWatchLogsFullAccess → Optional (for complete log publishing control)

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.ec2_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cw_logs_attach" {
  role       = aws_iam_role.ec2_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -----------------------------
# Instance Profile for EC2 Monitoring Role
# -----------------------------
resource "aws_iam_instance_profile" "ec2_monitoring_profile" {
  name = "${var.project_name}-ec2-monitoring-profile"
  role = aws_iam_role.ec2_monitoring_role.name
}


#########################
# EC2 Instances
#########################

# Backend Instance
resource "aws_instance" "webserver" {
  ami                    = "ami-00f46ccd1cbfb363e"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_web_sg.id]
  key_name               = aws_key_pair.ec2_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_monitoring_profile.name
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_name}-webserver"
  }
}

# MongoDB Instance
resource "aws_instance" "mongo" {
  ami                    = "ami-00f46ccd1cbfb363e"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = aws_key_pair.ec2_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_monitoring_profile.name
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_name}-mongo"
  }
}
