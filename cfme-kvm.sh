#!/bin/bash
set -x

# dnf install sshpass links wget ruby
# + run script as root user

cd /var/lib/libvirt/images

BASE=http://file.cloudforms.lab.eng.rdu2.redhat.com/builds/cfme/downstream_56/latest/
LATEST=$(links -dump $BASE | grep qcow2 | ruby -n -e '$_ =~ /([-.\w]*\.qcow2)/; puts $1')
#DOWNLOAD=http://file.cloudforms.lab.eng.rdu2.redhat.com/builds/cfme/5.6/latest/cfme-rhos-5.6.0.4-1.x86_64.qcow2
DOWNLOAD=$BASE/$LATEST

if [ ! -f $LATEST ]; then
  wget $DOWNLOAD
fi

# IMAGE=$(echo $DOWNLOAD | ruby -n -e 'puts $_.split("/").last')

NAME=nightly
virsh destroy $NAME
virsh undefine $NAME

IMAGE=$NAME-$LATEST
cp $LATEST $IMAGE

#virt-install --connect qemu:///system -n $NAME --ram 2048 --os-type=linux --os-variant=rhel5 --disk path=$IMAGE,device=disk,bus=virtio,format=qcow2 --vcpus=2 --vnc --import # --noautoconsole --import
virt-install --connect qemu:///system --ram 1024 -n $NAME -r 2048 --os-type=linux --os-variant=rhel5 --disk path=$IMAGE,device=disk,format=qcow2 --vcpus=2 --vnc --import --noautoconsole

MAC=''
while [ -z "$MAC" ]; do
  echo 'waiting for virtual machine to start'
  sleep 2
  MAC=$(virsh domiflist $NAME | grep network | ruby -n -e 'puts $_.split(/\s+/)[4]')
done

IP=''
while [ -z "$IP" ]; do
  echo 'waiting for IP address'
  sleep 2
  IP=$(ip neigh | grep $MAC | cut -d ' ' -f 1)
done

for (( ; ; )); do
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/22" && break
  echo 'waiting for ssh to start'
  sleep 2
done

# appliance_console_cli -r 10 -i -p serepes -k serepes
sshpass -p "smartvm" ssh -o StrictHostKeyChecking=no root@$IP -C 'appliance_console_cli -r 10 -i -p serepes -k serepes'

for (( ; ; )); do
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/443" && break
  echo 'waiting for HTTPS to start'
  sleep 2
done

google-chrome-stable http://$IP:443
