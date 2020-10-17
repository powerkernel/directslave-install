#!/bin/sh
apt install -y bind9
wget -O /usr/local/directslave.tar.gz https://directslave.com/download/directslave-3.3-advanced-all.tar.gz
tar -xzvf /usr/local/directslave.tar.gz -C /usr/local/
curl https://get.acme.sh | sh
source ~/.bashrc
acme.sh --issue -d $(hostname -f) --dns dns_cf --keylength ec-384 --preferred-chain  "ISRG"
mkdir -p /usr/local/directslave/ssl
acme.sh --install-cert --ecc -d hostcp.xyz --cert-file /usr/local/directslave/ssl/cert.pem --key-file /usr/local/directslave/ssl/key.pem --fullchain-file /usr/local/directslave/ssl/fullchain.pem --ca-file /usr/local/directslave/ssl/ca.pem
mv /usr/local/directslave/bin/directslave-linux-amd64 /usr/local/directslave/bin/directslave
wget -O /usr/local/directslave/etc/directslave.conf https://raw.githubusercontent.com/powerkernel/directslave-install/main/directslave.conf
sed -i "s/Change_this_line_to_something_long_&_secure/$(uuidgen)/g" /usr/local/directslave/etc/directslave.conf
sed -i "s/BINDUID/$(id -u bind)/g" /usr/local/directslave/etc/directslave.conf
sed -i "s/BINDGIU/$(id -u bind)/g" /usr/local/directslave/etc/directslave.conf
mkdir -p /var/lib/bind/slave
touch /var/lib/bind/slave/directslave.inc
echo "include \"/var/lib/bind/slave/directslave.inc\";" >> /etc/bind/named.conf
sed -i "s/listen-on-v6 { any; };/listen-on-v6 { any; };\n     allow-transfer {\"none\";};/g" /etc/bind/named.conf.options
touch /usr/local/directslave/etc/passwd
chmod +x /usr/local/directslave/bin/directslave
chown -R bind:bind /usr/local/directslave
chown -R bind:bind /var/lib/bind/slave
/usr/local/directslave/bin/directslave --password admin:$PASSWORD
wget -O /etc/systemd/system/directslave.service https://raw.githubusercontent.com/powerkernel/directslave-install/main/directslave.service
systemctl daemon-reload
systemctl enable directslave.service
service directslave start
acme.sh --install-cert --ecc -d $(hostname -f) --cert-file /usr/local/directslave/ssl/cert.pem --key-file /usr/local/directslave/ssl/key.pem --fullchain-file /usr/local/directslave/ssl/fullchain.pem --ca-file /usr/local/directslave/ssl/ca.pem --reloadcmd "service directslave restart"