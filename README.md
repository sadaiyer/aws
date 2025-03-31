# aws
aws cli and CF scripts

./aws-vpc-create-cli.sh VPC-A
./aws-create-ec2.sh Y VPC-A


./aws-vpc-create-cli.sh VPC-B
./aws-create-ec2.sh Y VPC-A


./aws-vpc-create-cli.sh VPC-C
./aws-create-ec2.sh Y VPC-A


To delete
Terminate all EC2 instances

Delete all EBS volumes

Delete VPC-B and VPC-C
For VPC-A
- delete nat gateway
- released elastic IP
- delete VPC-A
