# AWS VPC and EC2 Deployment Guide

## Prerequisites
- AWS CLI installed and configured
- Templates saved locally:
  - `vpc.yml` - VPC template
  - `ec2.yml` - EC2 template

## Deploy VPC-A

```bash
aws cloudformation create-stack \
  --stack-name vpc-a \ [[1]](https://docs.aws.amazon.com/codebuild/latest/userguide/cloudformation-vpc-template.html)
  --template-body file://vpc.yml \
  --parameters \
    ParameterKey=EnvironmentName,ParameterValue=VPC-A \
    ParameterKey=VpcCidr,ParameterValue=10.0.0.0/16 \
    ParameterKey=PublicSubnetCidr,ParameterValue=10.0.1.0/24 \
    ParameterKey=PrivateSubnetCidr,ParameterValue=10.0.2.0/24

# Wait for stack completion
aws cloudformation wait stack-create-complete --stack-name vpc-a
```

## Deploy VPC-B

```
aws cloudformation create-stack \
  --stack-name vpc-b \ [[2]](https://repost.aws/questions/QUvjD46q7OS3aY3xRiGcY4ng/cloudformation-question)
  --template-body file://vpc.yml \
  --parameters \
    ParameterKey=EnvironmentName,ParameterValue=VPC-B \
    ParameterKey=VpcCidr,ParameterValue=10.1.0.0/16 \
    ParameterKey=PublicSubnetCidr,ParameterValue=10.1.1.0/24 \
    ParameterKey=PrivateSubnetCidr,ParameterValue=10.1.2.0/24

# Wait for stack completion
aws cloudformation wait stack-create-complete --stack-name vpc-b
```

## Deploy VPC-B

```
aws cloudformation create-stack \
  --stack-name vpc-c \
  --template-body file://vpc.yml \
  --parameters \
    ParameterKey=EnvironmentName,ParameterValue=VPC-C \
    ParameterKey=VpcCidr,ParameterValue=10.2.0.0/16 \
    ParameterKey=PublicSubnetCidr,ParameterValue=10.2.1.0/24 \
    ParameterKey=PrivateSubnetCidr,ParameterValue=10.2.2.0/24

# Wait for stack completion
aws cloudformation wait stack-create-complete --stack-name vpc-c
```
## Deploy EC2 Instances in VPC-A

```
aws cloudformation create-stack \
  --stack-name ec2-vpc-a \
  --template-body file://ec2.yml \
  --parameters \
    ParameterKey=VpcName,ParameterValue=VPC-A \
    ParameterKey=KeyName,ParameterValue=EC2-US-EAST-1 \
    ParameterKey=InstanceType,ParameterValue=t2.micro \
    ParameterKey=AmiId,ParameterValue=ami-071226ecf16aa7d96

# Wait for stack completion
aws cloudformation wait stack-create-complete --stack-name ec2-vpc-a
```

## Verify Stack Creation

```
# Check VPC-A stack
aws cloudformation describe-stacks --stack-name vpc-a --query 'Stacks[0].StackStatus'

# Check VPC-B stack
aws cloudformation describe-stacks --stack-name vpc-b --query 'Stacks[0].StackStatus'

# Check VPC-C stack
aws cloudformation describe-stacks --stack-name vpc-c --query 'Stacks[0].StackStatus'

# Check EC2 Stack Status
aws cloudformation describe-stacks --stack-name ec2-vpc-a --query 'Stacks[0].StackStatus'
```

## Cleanup (When needed)

```
# Delete the EC2 
aws cloudformation delete-stack --stack-name ec2-vpc-a
aws cloudformation wait stack-delete-complete --stack-name ec2-vpc-a

# Delete the VPCs 
aws cloudformation delete-stack --stack-name vpc-c
aws cloudformation delete-stack --stack-name vpc-b
aws cloudformation delete-stack --stack-name vpc-a

aws cloudformation wait stack-delete-complete --stack-name vpc-c
aws cloudformation wait stack-delete-complete --stack-name vpc-b
aws cloudformation wait stack-delete-complete --stack-name vpc-a
```
