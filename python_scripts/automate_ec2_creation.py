import boto3
from botocore.exceptions import NoCredentialsError, ClientError

REGION = 'us-west-2'
AMI_ID = 'ami-0abcdef1234567890'              # Replace with a valid AMI ID
INSTANCE_TYPE = 't2.micro'
KEY_PAIR_NAME = 'your-key-pair-name'          # Replace with your key pair
SECURITY_GROUP_IDS = ['sg-0123456789abcdef0'] # Replace with security group ID(s)
SUBNET_ID = 'subnet-0abcdef1234567890'        # Replace with subnet ID
TAG_NAME = 'DevOps-Automated-Instance'

def create_ec2_instance(dry_run=False):
    try:
        session = boto3.Session(region_name=REGION)
        ec2 = session.resource('ec2')

        instances = ec2.create_instances(
            ImageId=AMI_ID,
            InstanceType=INSTANCE_TYPE,
            MinCount=1,
            MaxCount=1,
            KeyName=KEY_PAIR_NAME,
            SecurityGroupIds=SECURITY_GROUP_IDS,
            SubnetId=SUBNET_ID,
            TagSpecifications=[
                {
                    'ResourceType': 'instance',
                    'Tags': [{'Key': 'Name', 'Value': TAG_NAME}]
                }
            ],
            DryRun=dry_run
        )

        print(f"EC2 instance created: {instances[0].id}")
        return instances[0].id

    except NoCredentialsError:
        print("AWS credentials not found. Please configure them.")
    except ClientError as e:
        if 'DryRunOperation' in str(e):
            print("Dry run successful. Permissions are valid.")
        else:
            print(f"ClientError: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    create_ec2_instance(dry_run=False)
