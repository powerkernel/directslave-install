# directslave-install

## Archived

Please use https://github.com/powerkernel/docker-directslave

## ENV

```bash
export PASSWORD="YOUR_DIRECTSLAVE_PASSWORD"
export CF_Token="sdfsdfsdfljlbjkljlkjsdfoiwje"
export CF_Account_ID="xxxxxxxxxxxxx"
export CF_Zone_ID="xxxxxxxxxxxxx"
```

## For Ubuntu

```bash
curl https://raw.githubusercontent.com/powerkernel/directslave-install/main/install-ubuntu.sh | sh
```

## Config DirectAdmin

add to DirectAdmin named config:

```conf
notify explicit;
also-notify { directslave_IPs; };
allow-notify { directslave_IPs; };
allow-transfer { directslave_IPs; };
```

Then restart named and rewrite all .db

```bash
service named restart
echo "action=rewrite&value=named" >> /usr/local/directadmin/data/task.queue
```

## Other info

Test DNS: https://manytools.org/network/query-dns-records-online/go

Test zone transfer: https://hackertarget.com/zone-transfer/

DNS check: http://dns-checker.online-domain-tools.com/

Domain Check: https://www.dnsqueries.com/en/domain_check.php

IntoDNS Test: https://intodns.com/

Change DNS: https://help.directadmin.com/item.php?id=141
