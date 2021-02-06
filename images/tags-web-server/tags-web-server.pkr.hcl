source "amazon-ebs" "tags_web_server" {
  region        = "us-east-2"

  ami_name      = "tags-webserver"
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
  sources = ["source.amazon-ebs.tags_web_server"]

  provisioner "file" {
    sources = ["tags-file-generator.py", "poetry.lock", "pyproject.toml"]
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    sources = ["tags-web-server.sh", "tags-web-server.service"]
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
        "sudo chown -R $USER:$USER /var/www/",
        "sudo rm -rf /var/www/html/*",
        "sudo mv /tmp/tags-web-server.sh /usr/local/bin/tags-web-server.sh",
        "sudo mv /tmp/tags-web-server.service /etc/systemd/system/tags-web-server.service",
        "sudo chmod 744 /usr/local/bin/tags-web-server.sh",
        "sudo chmod 664 /etc/systemd/system/tags-web-server.service",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable tags-web-server.service"
      ]
  }
}
