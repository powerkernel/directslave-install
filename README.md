# directslave-install

export PASSWORD=`YOUR_DIRECTSLAVE_PASSWORD`

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

Change DNS: https://help.directadmin.com/item.php?id=141
