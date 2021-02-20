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

instances = ec2.describe_instances(Filters=[
    { 'Name': 'tag:App', 'Values': ['tags-web-server'] }
])

ips = []

for r in instances['Reservations']:
    for i in r['Instances']:
        if i.get('PrivateIpAddress') is not None:
            ips.append(i.get('PrivateIpAddress'))
            
servers = ""
for ip in ips:
    servers += f"server {ip};\n"

nginx_conf = """
events {
    worker_connections 10240;
}
http {
    upstream backend {
        %s
    }

    server {
        location / {
            proxy_pass http://backend;
        }
    }
}
""" % (servers)

with open('/etc/nginx/nginx.conf', 'w') as f:
    f.write(nginx_conf)
