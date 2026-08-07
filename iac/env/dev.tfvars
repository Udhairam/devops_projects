aws_region   = "us-east-1"
project_name = "devops"
environment  = "dev"

# Networking
vpc_cidr = "10.0.0.0/16"

# Compute
instance_type = "t3.micro"
asg_min       = 1
asg_desired   = 1
asg_max       = 3

# Storage
bucket_name = "devops-bucket-udhairam-20260208"

# Monitoring thresholds
cpu_scale_out_threshold = 75
cpu_scale_in_threshold  = 25
