#!/bin/bash

set -e -x
# Add dns trail, sudoers file, and cloud.cfg
echo "$DNA" >> /home/centos/dna.txt
sudo cp /home/centos/dna.txt /etc/dna.txt
sudo cp /home/centos/sudoers /etc/
sudo cp /home/centos/cloud.cfg /etc/cloud
# Restart Network Manager
sudo systemctl restart NetworkManager.service

# Install required CA certificates
#sudo wget <url/endpoint/to/CA/chain/p7b/file>
#sudo openssl pkcs7 -inform DER -in <wget/ca/cert/file.p7b> -print_certs -out <name/for/converted/cert.pem>
#sudo mv <name/for/converted/cert.pem> /etc/pki/ca-trust/source/anchors/<name/for/converted/cert.pem>
#sudo update-ca-trust extract

# Disable fastest mirror and public repos due to proxied environment (if no proxy, can omit)
# https://wiki.centos.org/PackageManagement/Yum/FastestMirror
if [[ -f /etc/yum/pluginconf.d/fastestmirror.conf ]]; then
  sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf

  # Disable Internet repos
  for file in `ls /etc/yum.repos.d/`; do sudo sed -i 's/enabled=1/enabled=0/g' "/etc/yum.repos.d/$file"; done
  sudo sed -i '/gpgcheck.*/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo
  sudo sed -i '/enabled=0/enabled=1/g' /etc/yum.repos.d/CentOS-Media.repo

fi

sudo dracut -f
sudo chmod 740 /etc/skel/.bash*
