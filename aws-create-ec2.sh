#!/bin/bash
#******************************************************************************
#    AWS VPC Creation Shell Script
#******************************************************************************
#
# SYNOPSIS
#    Automates the creation of a security group, key pair and EC2 instance in us-west-1
#
# DESCRIPTION
#    This shell script leverages the AWS Command Line Interface (AWS CLI) to
#    automatically create security group, key pair and EC2 instance.  
#    The script assumes the AWS CLI is
#    installed and configured with the necessary security credentials.
#    us-west-1 is "VPC-AWS"
#    and I want to create a micro ec2-instance in that VPC private subnet
#    only CREATES EC2 instance
#    Assumes, the VPC has been created before
#==============================================================================
#
# NOTES
#   VERSION:   0.1.0
#   LASTEDIT:  2/23/2025
#   AUTHOR:    Sada Iyer
#   EMAIL:     iyersada@gmail.com
#   REVISIONS:

#
#==============================================================================
#   MODIFY THE SETTINGS BELOW
#   https://devopscube.com/use-aws-cli-create-ec2-instance/
#==============================================================================
#


KEY_NAME=EC2-US-EAST-1                                       ##replace this###

AWS_REGION="us-east-1"

VPC_CIDR="10.0.0.0/16"

# logging
MOD_HOME=/Users/sadaiyer/Downloads/AWS              ##replace this
LOG_HOME=$MOD_HOME/LOG                              ##create this LOG directory
DATE_TIME_STAMP=$(date '+%Y_%m_%d_%H_%M_%S')
FILE_NAME=$2-aws-create-ec2-$DATE_TIME_STAMP.LOG

echo $FILE_NAME

#

echo "number of parameters passed is: " $#
echo "first parameter is :" $1
echo "second parameter is :" $2



if [ "$#" == "2" ]; then
  echo "Create Instance True/False value is: " $1
  VPC_NAME=$2
  echo "VPC_NAME is: " $VPC_NAME                                             | tee -a    $LOG_HOME/$FILE_NAME
else 
  echo "the 1st parameter of Y indicates whether to create the EC2 instance" | tee -a    $LOG_HOME/$FILE_NAME
  echo "the 2nd parameter is the VPC_NAME, pass VPC-A, VPC-B or VPC-C"       | tee -a    $LOG_HOME/$FILE_NAME
  echo "Usage: ./aws-create-ec2.sh  Y VPC_NAME"                              | tee -a    $LOG_HOME/$FILE_NAME
  exit 1
fi



if [ "$AWS_REGION" == "us-east-1" ]; then
  AMI_ID="ami-071226ecf16aa7d96"
fi 

SG_NAME=$VPC_NAME-SG
#

if [ "$1" == "Y" ]; then
  echo "Instance will be created"                       | tee -a    $LOG_HOME/$FILE_NAME

  echo "AMI used is     : " $AMI_ID                     | tee -a    $LOG_HOME/$FILE_NAME
  echo "Key Name used is: " $KEY_NAME                   | tee -a    $LOG_HOME/$FILE_NAME
  echo "VPC_NAME is     : " $VPC_NAME                   | tee -a    $LOG_HOME/$FILE_NAME
  echo "Security Group name created will be: " $SG_NAME | tee -a    $LOG_HOME/$FILE_NAME
  echo "Log File Name is: " $FILE_NAME                  | tee -a    $LOG_HOME/$FILE_NAME
else 
  echo "the first parameter of Y indicates whether to create the EC2 instance" | tee -a    $LOG_HOME/$FILE_NAME
  echo "Usage: ./aws-create-ec2.sh  Y"                | tee -a    $LOG_HOME/$FILE_NAME
  exit 1
fi


#
#==============================================================================
#   DO NOT MODIFY CODE BELOW
#==============================================================================
#
# Create VPC
echo "Get VPC_ID..."                                     | tee -a    $LOG_HOME/$FILE_NAME               

VPC_ID=$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$VPC_NAME --query "Vpcs[].VpcId" --region=$AWS_REGION --output text)
echo "VPC_ID is: " $VPC_ID                                          | tee -a    $LOG_HOME/$FILE_NAME


if [ -z "$VPC_ID" ]; then
    echo "Security Group ID does not exists, first time run."       | tee -a    $LOG_HOME/$FILE_NAME
else
    ##this is the "before" security_group_id
    SG_ID=$(aws ec2 describe-security-groups --filter Name=vpc-id,Values=$VPC_ID Name=group-name,Values=$SG_NAME --query 'SecurityGroups[*].[GroupId]' --region $AWS_REGION --output text)
    echo "Security Group ID is '$SG_ID' "                           | tee -a    $LOG_HOME/$FILE_NAME
    echo $SG_ID                                                     | tee -a    $LOG_HOME/$FILE_NAME

    echo "Delete Security Group if it exists"                       | tee -a    $LOG_HOME/$FILE_NAME
    aws ec2 delete-security-group --group-id $SG_ID --region $AWS_REGION
    echo "Security Group Deleted"                                   | tee -a    $LOG_HOME/$FILE_NAME

fi

# Create Security Group
echo "Creating Security Group..."                                  | tee -a    $LOG_HOME/$FILE_NAME
VPC_AWS_SG=$(aws ec2 create-security-group \
    --group-name $SG_NAME \
    --description $SG_NAME \
    --vpc-id $VPC_ID \
    --region $AWS_REGION)
 

echo "Security Group '$VPC_AWS_SG' CREATED IN VPCID '$VPC_ID'"      | tee -a    $LOG_HOME/$FILE_NAME

echo "Creating rules for security group"                            | tee -a    $LOG_HOME/$FILE_NAME

# this is the "after" security group id
SG_ID=$(aws ec2 describe-security-groups --filter Name=vpc-id,Values=$VPC_ID Name=group-name,Values=$SG_NAME --query 'SecurityGroups[*].[GroupId]' --region $AWS_REGION --output text)
echo "Security Group ID is '$SG_ID' "
echo $SG_ID                                                         | tee -a    $LOG_HOME/$FILE_NAME

aws ec2 create-tags \
  --resources $SG_ID \
  --tags "Key=Name,Value=$SG_NAME" \
  --region $AWS_REGION



aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol icmp \
    --port all \
    --cidr "10.0.0.0/8" \
    --region $AWS_REGION

echo "ICMP rule created"                                            | tee -a    $LOG_HOME/$FILE_NAME



if [ -e ~/.ssh/$KEY_NAME ]; then
 echo "Key Exists"                                                  | tee -a    $LOG_HOME/$FILE_NAME
else
 aws ec2 create-key-pair  --key-name  $KEY_NAME --region=$AWS_REGION --query 'KeyMaterial' --output text > ~/.ssh/$KEY_NAME
fi

PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" --region=$AWS_REGION --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' --output text)

echo "PRIVATE_SUBNET_ID is :" $PRIVATE_SUBNET_ID                                    | tee -a    $LOG_HOME/$FILE_NAME


if [ $1 = 'Y' ]; then
echo "Creating EC2 instance.."                                        | tee -a    $LOG_HOME/$FILE_NAME

PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" --region=$AWS_REGION --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' --output text)

echo "PRIVATE_SUBNET_ID is :" $PRIVATE_SUBNET_ID                                    | tee -a    $LOG_HOME/$FILE_NAME

aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --subnet-id $PRIVATE_SUBNET_ID \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-public}]' 'ResourceType=volume,Tags=[{Key=Name,Value=ec2-public}]' \
    --region $AWS_REGION \
    --no-cli-pager


        if [ "$VPC_NAME" == "VPC-A" ]; then
            PUBLIC_SUBNET_ID=$(aws ec2 describe-subnets \
                --filters "Name=vpc-id,Values=$VPC_ID" --region=$AWS_REGION --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output text)

            echo "PUBLIC_SUBNET_ID is :" $PUBLIC_SUBNET_ID                                    | tee -a    $LOG_HOME/$FILE_NAME

            aws ec2 run-instances \
            --image-id $AMI_ID \
            --count 1 \
            --instance-type t2.micro \
            --key-name $KEY_NAME \
            --security-group-ids $SG_ID \
            --associate-public-ip-address \
            --subnet-id $PUBLIC_SUBNET_ID \
            --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}}]" \
            --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-public}]' 'ResourceType=volume,Tags=[{Key=Name,Value=ec2-public}]' \
            --region $AWS_REGION \
            --no-cli-pager
        fi

fi

echo "COMPLETED"                                                    | tee -a    $LOG_HOME/$FILE_NAME
ls -l $LOG_HOME/$FILE_NAME
rm $LOG_HOME/$FILE_NAME