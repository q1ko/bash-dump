echo 'Acquire::http { Proxy "http://192.168.1.150:3142"; }' | sudo tee -a /etc/apt/apt.conf.d/proxy
sudo apt update && sudo apt upgrade -y
sudo apt install net-tools
