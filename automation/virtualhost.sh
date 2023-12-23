#!/bin/bash

insight() {
  sudo insights-client --register;
}

bootconf() {
  sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub &&
  echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub &&
  grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg ;
}


firewall() {
  sudo firewall-cmd --permanent --new-zone=coresys &&
  sudo firewall-cmd --permanent --new-zone=sysadm && 

  sudo firewall-cmd --permanent --zone="coresys" --add-source=172.27.5.81/24 &&
  sudo firewall-cmd --permanent --zone="coresys" --add-service=ssh &&

  sudo firewall-cmd --permanent --zone="sysadm" --add-source=172.27.5.71/24 &&
  sudo firewall-cmd --permanent --zone="sysadm" --add-source=172.27.5.72/24 &&

  sudo firewall-cmd --reload;
}


cockpit() {

  mkdir mkdir /etc/systemd/system/cockpit.socket.d/ &&
  touch /etc/systemd/system/cockpit.socket.d/listen.conf &&

  echo "[Socket]" >  /etc/systemd/system/cockpit.socket.d/listen.conf &&
  echo "ListenStream=" >  /etc/systemd/system/cockpit.socket.d/listen.conf &&
  echo "ListenStream=443" >  /etc/systemd/system/cockpit.socket.d/listen.conf &&


  sudo semanage port -m -t websm_port_t -p tcp 443 &&


  touch /etc/cockpit/cockpit.conf &&
  echo "[WebService]" >  /etc/cockpit/cockpit.conf &&
  echo "LoginTitle=Fakultas Adab dan Humaniora" > /etc/cockpit/cockpit.conf &&
  echo "LoginTo=false" >  /etc/cockpit/cockpit.conf &&

  sudo firewall-cmd --permanent --zone="coresys" --permanent --add-service=https &&
  sudo firewall-cmd --permanent --zone="sysadm" --permanent --add-service=https &&
  sudo firewall-cmd --permanent --zone="sysadm" --permanent --remove-service=cockpit &&
  sudo firewall-cmd --permanent --zone="public" --permanent --remove-service=cockpit &&
  sudo firewall-cmr --reload &&
  
  sudo systemctl daemon-reload &&
  sudo systemctl restart cockpit.socket;
}


podman() {
  dnf remove cockpit-podman &&
  dnf remove podman;
}


virtualizer() {
  dnf groupinstall "virtualization-host" &&
  dnf install cockpit-machines &&
  systemctl enable --now libvirtd;
}


insight && bootconf && firewall && cockpit && podman && virtualizer
