import boto3

# Setup
ec2 = boto3.resource('ec2', region_name='us-west-2')  # set your preferred region

# Create EC2 instance
instance = ec2.create_instances(
    ImageId='ami-0abcdef1234567890',  # replace with a valid AMI ID
    MinCount=1,
    MaxCount=1,
    InstanceType='t2.micro',
    TagSpecifications=[
        {
            'ResourceType': 'instance',
            'Tags': [{'Key': 'Name', 'Value': 'DevInstance'}]
        }
    ]
)[0]

print(f"EC2 Instance Created: {instance.id}")