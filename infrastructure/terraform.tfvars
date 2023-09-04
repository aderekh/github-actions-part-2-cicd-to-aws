vpc_id              = "vpc-042884a1f4f1e3b08"
Instance_type       = "t2.micro"
minsize             = 1
maxsize             = 2
public_subnets     = ["subnet-0552f9c9a440695b3", "subnet-0a2d2ff0b51802509"] # Service Subnet
elb_public_subnets = ["subnet-0552f9c9a440695b3", "subnet-0a2d2ff0b51802509"] # ELB Subnet
tier = "WebServer"
solution_stack_name= "64bit Amazon Linux 2023 v4.0.3 running Python 3.11"