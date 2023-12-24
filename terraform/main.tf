resource "aws_vpc" "vote_vpc" {
   cidr_block = "10.0.0.0/16" #It is just one of the private IP addresses  

  #These two are false in defualt
  enable_dns_hostnames = true #Instances in the VPC receive public DNS hostnames
  enable_dns_support   = true #Dns resolution = Convert Domain name into IP address

  tags = {
    Name = "vote_VPC" #It will show as name in AWS console
  }
}
  
resource "aws_subnet" "vote_public_subnet" {
  vpc_id                  = aws_vpc.vote_vpc.id
  cidr_block              = "10.0.1.0/24" #Must be inside of VPC cidr block and dont overlap with vpc cidr block
  map_public_ip_on_launch = true #Instances in the subnet will be asiigned with public IP
  availability_zone       = "us-southeast-2a"

  tags = {
    Name = "dev-public"
  }
}
resource "aws_subnet" "vote_private_subnet" {
  vpc_id                  = aws_vpc.vote_vpc.id
  cidr_block              = "10.0.2.0/24" #Must be inside of VPC cidr block and dont overlap with vpc cidr block
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-private"
  }
}
resource "aws_internet_gateway" "vote_ig" {
  vpc_id = aws_vpc.mk_vpc.id
  tags = {
    Name = "dev-ig"
  }
}
# A collections of rules
resource "aws_route_table" "vote_public_rt" {
  vpc_id = aws_vpc.vote_vpc.id
  tags = {
    Name = "dev-rt"
  }
}
# A route = A rule of outbound traffic
resource "aws_route" "vote_route" {
  route_table_id         = aws_route_table.vote_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vote_ig.id
}
# Assignment of a subnet to a RT. 
resource "aws_route_table_association" "vote_rt-assoc" {
  subnet_id      = aws_subnet.mk_public_subnet.id
  route_table_id = aws_route_table.mk_public_rt.id
}

# Create a security group for EC2 instances
resource "aws_security_group" "vote_app_sg" {
  name        = "vote-app-sg"
  description = "Security group for the vote app"
  vpc_id = aws_vpc.vote_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "vote_app_instance" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mk_sg.id]
  subnet_id              = aws_subnet.mk_public_subnet.id

  security_group = aws_security_group.vote_app_sg.id

  tags = {
    Name = "VoteAppInstance-${count.index}"
  }
}

# Create RDS instance
resource "aws_db_instance" "vote_app_db" {
  identifier           = "vote-app-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t2.micro"
  name                 = "vote_app_db"
  username             = "your-db-user"
  password             = "your-db-password"
  parameter_group_name = "default.postgres13"
}

# Output the public IP of one of the EC2 instances for convenience
output "app_instance_ip" {
  value = aws_instance.vote_app_instance[0].public_ip
}
