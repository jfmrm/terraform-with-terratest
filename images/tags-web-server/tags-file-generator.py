import boto3
import requests
from botocore.config import Config

token = str(requests.put('http://169.254.169.254/latest/api/token', 
                     headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"}).content, 'utf-8')
instance_id = str(requests.get('http://169.254.169.254/latest/meta-data/instance-id',
                          headers={"X-aws-ec2-metadata-token": token}).content, 'utf-8')
region = str(requests.get('http://169.254.169.254/latest/meta-data/placement/region',
                      headers={"X-aws-ec2-metadata-token": token}).content, 'utf-8')

my_config = Config(
    region_name = region,
)

ec2 = boto3.client('ec2', config=my_config)

tags = ec2.describe_tags(
    Filters=[
        {
            'Name': 'resource-id',
            'Values': [
                instance_id,
            ]
        },
    ],
)

with open('/var/www/html/index.html', mode='w', encoding='utf-8') as f:
    for tag in tags['Tags']:
        f.write(f"{tag['Key']}={tag['Value']}\n")
