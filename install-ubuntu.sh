#!/bin/sh

# Auto Restart
sed -i "s/\/\/Unattended-Upgrade::Automatic-Reboot \"false\";/Unattended-Upgrade::Automatic-Reboot \"true\";/g" /etc/apt/apt.conf.d/50unattended-upgrades

# install software
apt install -y bind9 uuid-runtime cron

# install directslave
wget -O /usr/local/directslave.tar.gz https://directslave.com/download/directslave-3.4.2-advanced-all.tar.gz
tar -xzvf /usr/local/directslave.tar.gz -C /usr/local/

# install acmesh & configure ssl
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca  --server  letsencrypt
~/.acme.sh/acme.sh --issue -d $(hostname -f) --dns dns_cf --keylength ec-384 --preferred-chain  "ISRG"
rm /usr/local/directslave/ssl/*
~/.acme.sh/acme.sh --install-cert --ecc -d $(hostname -f) --cert-file /usr/local/directslave/ssl/cert.pem --key-file /usr/local/directslave/ssl/key.pem --fullchain-file /usr/local/directslave/ssl/fullchain.pem --ca-file /usr/local/directslave/ssl/ca.pem

# configure directslave
mv /usr/local/directslave/bin/directslave-linux-amd64 /usr/local/directslave/bin/directslave
wget -O /usr/local/directslave/etc/directslave.conf https://raw.githubusercontent.com/powerkernel/directslave-install/main/directslave.conf
sed -i "s/Change_this_line_to_something_long_&_secure/$(uuidgen)/g" /usr/local/directslave/etc/directslave.conf
sed -i "s/BINDUID/$(id -u bind)/g" /usr/local/directslave/etc/directslave.conf
sed -i "s/BINDGIU/$(id -u bind)/g" /usr/local/directslave/etc/directslave.conf
mkdir -p /var/lib/bind/slave
touch /var/lib/bind/slave/directslave.inc

# configure bind9
echo "include \"/var/lib/bind/slave/directslave.inc\";" >> /etc/bind/named.conf
sed -i "s/listen-on-v6 { any; };/#listen-on-v6 { any; };/g" /etc/bind/named.conf.options
echo "listen-on port 53 { any; };" >> /etc/bind/named.conf.options
echo "listen-on-v6 port 53 { any; };" >> /etc/bind/named.conf.options
echo "allow-transfer {\"none\";};" >> /etc/bind/named.conf.options

# permission
touch /usr/local/directslave/etc/passwd
chmod +x /usr/local/directslave/bin/directslave
chown -R bind:bind /usr/local/directslave
chown -R bind:bind /var/lib/bind/slave
/usr/local/directslave/bin/directslave --password admin:$PASSWORD
wget -O /etc/systemd/system/directslave.service https://raw.githubusercontent.com/powerkernel/directslave-install/main/directslave.service
systemctl daemon-reload
systemctl enable directslave.service
service directslave start
~/.acme.sh/acme.sh --install-cert --ecc -d $(hostname -f) --cert-file /usr/local/directslave/ssl/cert.pem --key-file /usr/local/directslave/ssl/key.pem --fullchain-file /usr/local/directslave/ssl/fullchain.pem --ca-file /usr/local/directslave/ssl/ca.pem --reloadcmd "service directslave restart"

# remove iptables
apt remove iptables -y
