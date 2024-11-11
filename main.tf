provider "aws" {
    region = "ap-south-1"
}
#S3_bucket

#VPC
resource "aws_vpc" "Demo_VPC" {
    cidr_block = "10.0.0.0/16"

    tags = {  
      Name = "Demo-VPC"
    }
}

#Public Subnets
resource "aws_subnet" "Demo_Public_Subnet_1" {
    vpc_id = aws_vpc.Demo_VPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"

    tags = {
      Name = "Demo-Public-Subnet-1"
    }
}

resource "aws_subnet" "Demo_Public_Subnet_2" {
    vpc_id = aws_vpc.Demo_VPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"

    tags = {
      Name = "Demo-Public-Subnet-2"
    }
}

#Private Subnets
#App Subnets

resource "aws_subnet" "Demo_Private_APP_Subnet_1" {
    vpc_id = aws_vpc.Demo_VPC.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-south-1a"

    tags = {
      Name = "Demo-Private-APP-Subnet-1"
    }
}

resource "aws_subnet" "Demo_Private_APP_Subnet_2" {
    vpc_id = aws_vpc.Demo_VPC.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "ap-south-1b"

    tags = {
      Name = "Demo-Private-APP-Subnet-2"
    }
}
#DB Subnets
resource "aws_subnet" "Demo_Private_DB_Subnet_1" {
    vpc_id = aws_vpc.Demo_VPC.id
    cidr_block = "10.0.5.0/24"
    availability_zone = "ap-south-1a"

    tags = {
      Name = "Demo-Private-DB-Subnet-1"
    }
}
resource "aws_subnet" "Demo_Private_DB_Subnet_2" {
    vpc_id = aws_vpc.Demo_VPC.id
    cidr_block = "10.0.6.0/24"
    availability_zone = "ap-south-1b"

    tags = {
      Name = "Demo-Private-DB-Subnet-2"
    }
}

#IGW
resource "aws_internet_gateway" "Demo_Internet_Gateway" {
    vpc_id = aws_vpc.Demo_VPC.id

    tags = {
      Name = "Demo_IGW"
    }
}

#Route Table-1
resource "aws_route_table" "Demo_Public_Route_Table_1" {
  vpc_id = aws_vpc.Demo_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Demo_Internet_Gateway.id
  }

  tags = {
    Name = "Demo-Public-Route-Table_1"
  }
}

#Route table association_1
resource "aws_route_table_association" "Demo_Public_Route_Teble_1_association_1" {
    subnet_id = aws_subnet.Demo_Public_Subnet_1.id
    route_table_id = aws_route_table.Demo_Public_Route_Table_1.id
}
#Route table association_2
resource "aws_route_table_association" "Demo_Public_Route_Teble_1_association_2" {
    subnet_id = aws_subnet.Demo_Public_Subnet_2.id
    route_table_id = aws_route_table.Demo_Public_Route_Table_1.id
}
#Elastic IP
# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "Demo_Elastic_IP" {
    domain = "vpc"
}

# Create the NAT Gateway and associate it with the Elastic IP
resource "aws_nat_gateway" "Demo_nat_gateway" {
  allocation_id = aws_eip.Demo_Elastic_IP.id  # Reference the Elastic IP's ID here
  subnet_id     = aws_subnet.Demo_Public_Subnet_1.id

  tags = {
    Name = "NAT-Gateway"
  }
}
#Route Table-2
resource "aws_route_table" "Demo_Private_Route_Table_1" {
  vpc_id = aws_vpc.Demo_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Demo_nat_gateway.id
  }

  tags = {
    Name = "Demo-Private-Route-Table_1"
  }
}

#Route table association_1
resource "aws_route_table_association" "Demo_Private_Route_Teble_1_association_1" {
    subnet_id = aws_subnet.Demo_Private_APP_Subnet_1.id
    route_table_id = aws_route_table.Demo_Private_Route_Table_1.id
}
#Route table association_2
resource "aws_route_table_association" "Demo_Private_Route_Teble_1_association_2" {
    subnet_id = aws_subnet.Demo_Private_APP_Subnet_2.id
    route_table_id = aws_route_table.Demo_Private_Route_Table_1.id
}

#ELB-Security-Group

resource "aws_security_group" "Demo_Web_ELB_Security_Group" {
  vpc_id = aws_vpc.Demo_VPC.id

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "Demo-Web-ELB-Security-Group-1"
  }
}

#WEB-Security-Group
resource "aws_security_group" "Demo_Web_Security_Group" {
  vpc_id = aws_vpc.Demo_VPC.id

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [aws_security_group.Demo_Web_ELB_Security_Group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "Demo-Web-Security-Group-2"
  }
}

#APP-ALB-Security-Group
resource "aws_security_group" "Demo_App-ALB_Security_Group" {
  vpc_id = aws_vpc.Demo_VPC.id

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    security_groups = [aws_security_group.Demo_Web_Security_Group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "Demo-App-ALB-Security-Group-3"
  }
}

resource "aws_security_group" "Demo_App_Security_Group" {
  vpc_id = aws_vpc.Demo_VPC.id

  ingress {
    protocol  = "tcp"
    from_port = 4000
    to_port   = 4000
    security_groups = [aws_security_group.Demo_App-ALB_Security_Group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "Demo-ALB-Security-Group-4"
  }
}

#DB-Security Group
resource "aws_security_group" "Demo_DB_Secutiry_Group" {
  vpc_id = aws_vpc.Demo_VPC.id

  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    security_groups = [aws_security_group.Demo_App_Security_Group.id]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "Demo-DB-Security-Group-5"
  }
}
/*
#DB-subnet-group
resource "aws_db_subnet_group" "DB_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.Demo_Private_DB_Subnet_1.id, aws_subnet.Demo_Private_DB_Subnet_2.id]

  tags = {
    Name = "DB-subnet-group"
  }
}

resource "aws_db_instance" "Demo_DB_Instance" {
    allocated_storage       = 20
    db_name                 = "mydb"
    engine                  = "mysql"
    engine_version          = "8.0"
    instance_class          = "db.t4g.micro"
    username                = "admin"
    password                = "admin123456!"
    parameter_group_name    = "default.mysql8.0"
    skip_final_snapshot     = true
    vpc_security_group_ids  = [aws_security_group.Demo_DB_Secutiry_Group.id]
    db_subnet_group_name    = aws_db_subnet_group.DB_subnet_group.name

    tags = {
      Name = "Demo-DB-Instance"
    }
}
*/
# IAM Role for Systems Manager
resource "aws_iam_role" "Demo_SSM_Role_mumbai" {
  name = "Demo-SSM-Role-mumbai"
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
}

# Attach SSM policy to IAM Role
resource "aws_iam_role_policy_attachment" "Demo_SSM_Policy_Attachment_mumbai" {
  role       = aws_iam_role.Demo_SSM_Role_mumbai.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
}

#App Instance in Private subnet

resource "aws_instance" "Demo_Proj_App_instance" {
    ami = "ami-04a37924ffe27da53"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.Demo_App_Security_Group.id]
    subnet_id = aws_subnet.Demo_Private_APP_Subnet_1.id
    iam_instance_profile = aws_iam_instance_profile.Demo_Instance_Profile_mumbai.id
    
    
    tags = {
      Name = "Demo-Proj-App-instance-1"
    }
}

# IAM Instance Profile for attaching the role to EC2
resource "aws_iam_instance_profile" "Demo_Instance_Profile_mumbai" {
  name = "Demo-Instance-Profile-mumbai"
  role = aws_iam_role.Demo_SSM_Role_mumbai.name
}
/*
#Application LB target group
resource "aws_lb_target_group" "Demo_App_LB_target_group" {
    name = "App-Target-group"
    port = 4000
    protocol = "HTTP"
    vpc_id = aws_vpc.Demo_VPC.id
    target_type = "instance"

    health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "App-Target-Group"
  }
}

# Register Instances with Target Group
resource "aws_lb_target_group_attachment" "app_targets" {
  target_group_arn = aws_lb_target_group.Demo_App_LB_target_group.arn
  target_id        = aws_instance.Demo_Proj_App_instance.id
  port             = 4000
}

#ALB creation
resource "aws_lb" "Demo_App_internal_LB" {
    name = "Demo-App-internal-LB"
    internal = true
    load_balancer_type = "application"
    security_groups = [aws_security_group.Demo_App-ALB_Security_Group.id]
    subnets = [aws_subnet.Demo_Private_APP_Subnet_1.id, aws_subnet.Demo_Private_APP_Subnet_2.id]

    tags = {
      Environment = "production"
  }
}
# Create Listener for HTTP (port 80)
resource "aws_lb_listener" "Demo_APP_internal_LB_listener" {
    load_balancer_arn = aws_lb.Demo_App_internal_LB.arn
    port = 80
    protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Demo_App_LB_target_group.arn
  }

}
# Output the ALB DNS name
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.Demo_App_internal_LB.dns_name
}
*/
resource "aws_instance" "Demo_Proj_Web_instance" {
    ami = "ami-04a37924ffe27da53"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.Demo_Web_Security_Group.id]
    subnet_id = aws_subnet.Demo_Public_Subnet_1.id
    iam_instance_profile = aws_iam_instance_profile.Demo_Instance_Profile_mumbai.id
    associate_public_ip_address = true
           
    tags = {
      Name = "Demo-Proj-Web-instance-1"
    }
}

resource "aws_vpc" "example_1" {
  cidr_block = "11.0.0.0/16"
}