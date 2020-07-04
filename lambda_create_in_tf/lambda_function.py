import os
import boto3

AMI = os.environ['ami-09d95fab7fff3776c']
INSTANCE_TYPE = os.environ['t2.micro']
KEY_NAME = os.environ['virginia']
SUBNET_ID = os.environ['My_VPC_Subnet']

ec2 = boto3.resource('ec2')


def lambda_handler(event, context):

    instance = ec2.create_instances(
        ImageId=AMI,
        InstanceType=INSTANCE_TYPE,
        KeyName=KEY_NAME,
        SubnetId=SUBNET_ID,
        MaxCount=1,
        MinCount=1
    )

    print("New instance created:", instance[0].id)
