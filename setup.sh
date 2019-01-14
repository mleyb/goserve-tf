#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo docker pull mleybourne/goserve:latest
sudo docker run -d -p 80:8081 mleybourne/goserve:latest