source "amazon-ebs" "loadbalancer" {
  region        = "us-east-2"

  ami_name      = "custom-nginx-load-balancer"
  instance_type = "t2.micro"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # canonical
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.loadbalancer"]

  provisioner "file" {
    sources = ["generate-config.py", "poetry.lock", "pyproject.toml"]
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    sources = ["update-config.sh", "update-config.service", "update-config.timer"]
    destination = "/tmp/"
  }
  
  provisioner "shell" {
      inline = [
        "/usr/bin/cloud-init status --wait",
        "sudo apt-get update -y",
        "sudo apt-get install -y nginx python3-pip python3-testresources",
        "pip3 install poetry",
        "export PATH=$PATH:/home/ubuntu/.local/bin",
        "poetry export --without-hashes -f requirements.txt -o requirements.txt",
        "pip3 install -r requirements.txt",
        "sudo chown -R $USER:$USER /etc/nginx/",
        "sudo mv /tmp/update-config.sh /usr/local/bin/update-config.sh",
        "sudo mv /tmp/update-config.service /etc/systemd/system/update-config.service",
        "sudo mv /tmp/update-config.timer /etc/systemd/system/update-config.timer",
        "sudo chmod 744 /usr/local/bin/update-config.sh",
        "sudo chmod 664 /etc/systemd/system/update-config.service",
        "sudo chmod 664 /etc/systemd/system/update-config.service",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable update-config.timer"
      ]
  }
}
