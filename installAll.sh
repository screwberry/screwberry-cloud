# Installs Docker and Grafana on the VM
sudo apt-get update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt-get update
sudo apt-get install -y docker-ce
# sudo apt-get install docker-ce docker-ce-cli containerd.io -y
docker run -d -p 3000:3000 grafana/grafana
exit 0