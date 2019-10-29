#!/bin/bash
set -x

# dnf install sshpass links wget ruby
# + run script as root user

cd /var/lib/libvirt/images

if [ ! -f "$LATEST" ]; then
  #BASE=http://file.cloudforms.lab.eng.rdu2.redhat.com/builds/cfme/5.10/5.10.0.24
  BASE=http://file.cloudforms.lab.eng.rdu2.redhat.com/builds/cfme/5.11/5.11.0.27
  LATEST=$(links -dump $BASE | grep qcow2 | grep rhevm | ruby -n -e '$_ =~ /([-.\w]*\.qcow2)/; puts $1')
  DOWNLOAD=$BASE/$LATEST

  if [ ! -f "$LATEST" ]; then
    echo $(tput bold)DOWNLOAD: $DOWNLOAD $(tput sgr0)
    wget $DOWNLOAD
  fi
fi

NAME=${1-nightly}

virsh destroy $NAME
virsh undefine $NAME

IMAGE=$NAME-$LATEST
cp $LATEST $IMAGE

DB_IMAGE=/var/lib/libvirt/images/miq-db.qcow2
qemu-img create -f qcow2 $DB_IMAGE 500M

echo $(tput bold)Installing in QEMU $(tput sgr0)
virt-install --connect qemu:///system -n $NAME --memory 4096 \
	--os-type=linux --os-variant=rhel6 --disk path=$IMAGE,device=disk,format=qcow2 --vcpus=2 --vnc --import --noautoconsole --cpu host \
	--disk path=$DB_IMAGE,device=disk,format=qcow2

MAC=''
while [ -z "$MAC" ]; do
  echo $(tput bold)Waiting for virtual machine to start $(tput sgr0)
  sleep 2
  MAC=$(virsh domiflist $NAME | grep network | ruby -n -e 'puts $_.split(/\s+/)[4]')
done

IP=''
while [ -z "$IP" ]; do
  echo $(tput bold)Waiting for IP address $(tput sgr0)
  sleep 2
  IP=$(ip neigh | grep $MAC | cut -d ' ' -f 1)
done

for (( ; ; )); do
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/22" && break
  echo $(tput bold)Waiting for ssh to start $(tput sgr0)
  sleep 2
done

exit
# appliance_console_cli -r 10 -i -p serepes -k serepes
sshpass -p "smartvm" ssh -o StrictHostKeyChecking=no root@$IP -C 'appliance_console_cli -r 10 -i -p serepes -k serepes --force-key --dbdisk /dev/vdb'

for (( ; ; )); do
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/443" && break
  echo $(tput bold)Waiting for HTTPS to start $(tput sgr0)
  sleep 2
done

echo google-chrome-stable https://$IP
