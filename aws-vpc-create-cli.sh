#!/bin/bash
#******************************************************************************
#    AWS VPC Creation Shell Script
#******************************************************************************
#
# SYNOPSIS
#    Automates the creation of a custom IPv4 VPC, having both a public and a
#    private subnet, and a NAT gateway.
#
# DESCRIPTION
#    This shell script leverages the AWS Command Line Interface (AWS CLI) to
#    automatically create a custom VPC.  The script assumes the AWS CLI is
#    installed and configured with the necessary security credentials.
#
#==============================================================================
#
# NOTES
#   VERSION:   0.1.0
#   LASTEDIT:  3/22/2025
#   AUTHOR:    Sada Iyer
#   EMAIL:     iyersada@gmail.com
#   REVISIONS:
#       0.1.0  03/22/2025 - initial release
#
#==============================================================================
#   MODIFY THE SETTINGS BELOW
#==============================================================================
#
AWS_REGION="us-east-1"
VPC_NAME=$1
SG_NAME=$VPC_NAME-SG

if [ "$AWS_REGION" == "us-east-1" ]; then
  AMI_ID=ami-071226ecf16aa7d96 
fi 

KEY_NAME="EC2-US-EAST-1"

# logging
#
MOD_HOME=/Users/sadaiyer/Downloads/AWS              ##replace this
LOG_HOME=$MOD_HOME/LOG                              ##create this LOG directory

DATE_TIME_STAMP=$(date '+%Y_%m_%d_%H_%M_%S')
FILE_NAME=$VPC_NAME-$DATE_TIME_STAMP

#
# Parameter to pass is VPC-A or VPC-B or VPC-C
#
if [ $# -ne 1 ]; then
  echo "Usage: ./aws-create-vpc-cli.sh  VPC-A|VPC-B|VPC-C"                | tee -a    $LOG_HOME/$FILE_NAME
  exit 1
fi


if [ "$1" == "VPC-A" ]; then
  VPC_CIDR="10.0.0.0/16"
  SUBNET_PUBLIC_CIDR="10.0.1.0/24"
  SUBNET_PUBLIC_AZ="us-east-1a"
  SUBNET_PUBLIC_NAME="10.0.1.0-us-east-1a-pub"

  SUBNET_PRIVATE_CIDR="10.0.2.0/24"
  SUBNET_PRIVATE_AZ="us-east-1b"
  SUBNET_PRIVATE_NAME="10.0.2.0-us-east-1b-pvt"
  CHECK_FREQUENCY=5
elif [ "$1" == "VPC-B" ]; then
  VPC_CIDR="10.1.0.0/16"
  SUBNET_PUBLIC_CIDR="10.1.1.0/24"
  SUBNET_PUBLIC_AZ="us-east-1a"
  SUBNET_PUBLIC_NAME="10.1.1.0-us-east-1a-pub"

  SUBNET_PRIVATE_CIDR="10.1.2.0/24"
  SUBNET_PRIVATE_AZ="us-east-1b"
  SUBNET_PRIVATE_NAME="10.1.2.0-us-east-1b-pvt"
  CHECK_FREQUENCY=5

elif [ "$1" == "VPC-C" ]; then
  VPC_CIDR="10.2.0.0/16"
  SUBNET_PUBLIC_CIDR="10.2.1.0/24"
  SUBNET_PUBLIC_AZ="us-east-1a"
  SUBNET_PUBLIC_NAME="10.2.1.0-us-east-1a-pub"

  SUBNET_PRIVATE_CIDR="10.2.2.0/24"
  SUBNET_PRIVATE_AZ="us-east-1b"
  SUBNET_PRIVATE_NAME="10.2.2.0-us-east-1b-pvt"
  CHECK_FREQUENCY=5
fi


# All good here, now echo and write the variables
echo "VPC_NAME is                           : " $VPC_NAME                   | tee -a    $LOG_HOME/$FILE_NAME
echo "AMI used is                           : " $AMI_ID                     | tee -a    $LOG_HOME/$FILE_NAME
echo "Key Name used is                      : " $KEY_NAME                   | tee -a    $LOG_HOME/$FILE_NAME
echo "VPC_NAME is                           : " $VPC_NAME                   | tee -a    $LOG_HOME/$FILE_NAME
echo "Security Group name created will be   : " $SG_NAME                    | tee -a    $LOG_HOME/$FILE_NAME
echo "Log File Name is                      : " $FILE_NAME                  | tee -a    $LOG_HOME/$FILE_NAME
echo "SUBNET_PUBLIC_CIDR is                 : " $SUBNET_PUBLIC_CIDR         | tee -a    $LOG_HOME/$FILE_NAME
echo "SUBNET_PRIVATE_CIDR is                : " $SUBNET_PRIVATE_CIDR        | tee -a    $LOG_HOME/$FILE_NAME
echo "SUBNET_PUBLIC_AZ is                   : " $SUBNET_PUBLIC_AZ           | tee -a    $LOG_HOME/$FILE_NAME
echo "SUBNET_PRIVATE_AZ is                  : " $SUBNET_PRIVATE_AZ          | tee -a    $LOG_HOME/$FILE_NAME




#
#==============================================================================
#   DO NOT MODIFY CODE BELOW
#==============================================================================
#
# Create VPC
echo "Creating VPC in preferred region..."                                  | tee -a    $LOG_HOME/$FILE_NAME
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $AWS_REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."                  | tee -a    $LOG_HOME/$FILE_NAME

# Add Name tag to VPC
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags "Key=Name,Value=$VPC_NAME" \
  --region $AWS_REGION
echo "  VPC ID '$VPC_ID' NAMED as '$VPC_NAME'."                             | tee -a    $LOG_HOME/$FILE_NAME


if [ "$1" == "VPC-A" ]; then
      # Create Public Subnet
      echo "Creating Public Subnet..."
      SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block $SUBNET_PUBLIC_CIDR \
        --availability-zone $SUBNET_PUBLIC_AZ \
        --query 'Subnet.{SubnetId:SubnetId}' \
        --output text \
        --region $AWS_REGION)
      echo "  Subnet ID '$SUBNET_PUBLIC_ID' CREATED in '$SUBNET_PUBLIC_AZ'" \                 
        "Availability Zone."                                                | tee -a    $LOG_HOME/$FILE_NAME

      # Add Name tag to Public Subnet
      aws ec2 create-tags \
        --resources $SUBNET_PUBLIC_ID \
        --tags "Key=Name,Value=$SUBNET_PUBLIC_NAME" \
        --region $AWS_REGION
      echo "  Subnet ID '$SUBNET_PUBLIC_ID' NAMED as" \
        "'$SUBNET_PUBLIC_NAME'."                                            | tee -a    $LOG_HOME/$FILE_NAME


      # Create Internet gateway
      echo "Creating Internet Gateway..."
      IGW_ID=$(aws ec2 create-internet-gateway \
        --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
        --output text \
        --region $AWS_REGION)
      echo "  Internet Gateway ID '$IGW_ID' CREATED."                               | tee -a    $LOG_HOME/$FILE_NAME

      # Attach Internet gateway to your VPC
      aws ec2 attach-internet-gateway \
        --vpc-id $VPC_ID \
        --internet-gateway-id $IGW_ID \
        --region $AWS_REGION
      echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."           | tee -a    $LOG_HOME/$FILE_NAME

      # Create Route Table
      echo "Creating Route Table..."
      ROUTE_TABLE_ID=$(aws ec2 create-route-table \
        --vpc-id $VPC_ID \
        --query 'RouteTable.{RouteTableId:RouteTableId}' \
        --output text \
        --region $AWS_REGION)
      echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."                              | tee -a    $LOG_HOME/$FILE_NAME

      # Create route to Internet Gateway
      RESULT=$(aws ec2 create-route \
        --route-table-id $ROUTE_TABLE_ID \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id $IGW_ID \
        --region $AWS_REGION)
      echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
        "Route Table ID '$ROUTE_TABLE_ID'."                                           | tee -a    $LOG_HOME/$FILE_NAME

      # Associate Public Subnet with Route Table
      RESULT=$(aws ec2 associate-route-table  \
        --subnet-id $SUBNET_PUBLIC_ID \
        --route-table-id $ROUTE_TABLE_ID \
        --region $AWS_REGION)
      echo "  Public Subnet ID '$SUBNET_PUBLIC_ID' ASSOCIATED with Route Table ID" \
        "'$ROUTE_TABLE_ID'."                                                          | tee -a    $LOG_HOME/$FILE_NAME

      # Enable Auto-assign Public IP on Public Subnet
      aws ec2 modify-subnet-attribute \
        --subnet-id $SUBNET_PUBLIC_ID \
        --map-public-ip-on-launch \
        --region $AWS_REGION
      echo "  'Auto-assign Public IP' ENABLED on Public Subnet ID" \
        "'$SUBNET_PUBLIC_ID'."                                                        | tee -a    $LOG_HOME/$FILE_NAME

      # Allocate Elastic IP Address for NAT Gateway
      echo "Creating NAT Gateway..."
      EIP_ALLOC_ID=$(aws ec2 allocate-address \
        --domain vpc \
        --query '{AllocationId:AllocationId}' \
        --output text \
        --region $AWS_REGION)
      echo "  Elastic IP address ID '$EIP_ALLOC_ID' ALLOCATED."                         | tee -a    $LOG_HOME/$FILE_NAME

      # Create NAT Gateway
      NAT_GW_ID=$(aws ec2 create-nat-gateway \
        --subnet-id $SUBNET_PUBLIC_ID \
        --allocation-id $EIP_ALLOC_ID \
        --query 'NatGateway.{NatGatewayId:NatGatewayId}' \
        --output text \
        --region $AWS_REGION)
      FORMATTED_MSG="Creating NAT Gateway ID '$NAT_GW_ID' and waiting for it to "
      FORMATTED_MSG+="become available.\n    Please BE PATIENT as this can take some "
      FORMATTED_MSG+="time to complete.\n    ......\n"
      printf "  $FORMATTED_MSG"
      FORMATTED_MSG="STATUS: %s  -  %02dh:%02dm:%02ds elapsed while waiting for NAT "
      FORMATTED_MSG+="Gateway to become available..."
      SECONDS=0
      LAST_CHECK=0
      STATE='PENDING'
      until [[ $STATE == 'AVAILABLE' ]]; do
        INTERVAL=$SECONDS-$LAST_CHECK
        if [[ $INTERVAL -ge $CHECK_FREQUENCY ]]; then
          STATE=$(aws ec2 describe-nat-gateways \
            --nat-gateway-ids $NAT_GW_ID \
            --query 'NatGateways[*].{State:State}' \
            --output text \
            --region $AWS_REGION)
          STATE=$(echo $STATE | tr '[:lower:]' '[:upper:]')
          LAST_CHECK=$SECONDS
        fi
        SECS=$SECONDS
        STATUS_MSG=$(printf "$FORMATTED_MSG" \
          $STATE $(($SECS/3600)) $(($SECS%3600/60)) $(($SECS%60)))
        printf "    $STATUS_MSG\033[0K\r"
        sleep 1
      done
      printf "\n    ......\n  NAT Gateway ID '$NAT_GW_ID' is now AVAILABLE.\n"

      # Create route to NAT Gateway
      MAIN_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
        --filters Name=vpc-id,Values=$VPC_ID Name=association.main,Values=true \
        --query 'RouteTables[*].{RouteTableId:RouteTableId}' \
        --output text \
        --region $AWS_REGION)
      echo "  Main Route Table ID is '$MAIN_ROUTE_TABLE_ID'."                        | tee -a    $LOG_HOME/$FILE_NAME
      RESULT=$(aws ec2 create-route \
        --route-table-id $MAIN_ROUTE_TABLE_ID \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id $NAT_GW_ID \
        --region $AWS_REGION)
      echo "  Route to '0.0.0.0/0' via NAT Gateway with ID '$NAT_GW_ID' ADDED to" \
        "Route Table ID '$MAIN_ROUTE_TABLE_ID'."                                     | tee -a    $LOG_HOME/$FILE_NAME


fi


#
# Create Private Subnet
#
echo "Creating Private Subnet..."
SUBNET_PRIVATE_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE_CIDR \
  --availability-zone $SUBNET_PRIVATE_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PRIVATE_ID' CREATED in '$SUBNET_PRIVATE_AZ'" \
  "Availability Zone."                                                            | tee -a    $LOG_HOME/$FILE_NAME

# Add Name tag to Private Subnet
aws ec2 create-tags \
  --resources $SUBNET_PRIVATE_ID \
  --tags "Key=Name,Value=$SUBNET_PRIVATE_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PRIVATE_ID' NAMED as '$SUBNET_PRIVATE_NAME'."           | tee -a    $LOG_HOME/$FILE_NAME



echo "COMPLETED"