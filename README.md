# aws
aws cli and CF scripts

# VPC-A
## VPC-A will have one public subnet, one private subnet, security group, IGW and Nat GW
./aws-vpc-create-cli.sh VPC-A

./aws-create-ec2.sh Y VPC-A

# VPC-B
## VPC-B will have one private subnet
./aws-vpc-create-cli.sh VPC-B

## This will create an EC2 instance in the private subnet
./aws-create-ec2.sh Y VPC-B


# VPC-C
## VPC-C will have one private subnet
./aws-vpc-create-cli.sh VPC-C

## This will create an EC2 instance in the private subnet
./aws-create-ec2.sh Y VPC-C


# To delete all resources
Terminate all EC2 instances

Delete all EBS volumes

Delete VPC-B and VPC-C
For VPC-A
- delete nat gateway
- released elastic IP
- delete VPC-A
