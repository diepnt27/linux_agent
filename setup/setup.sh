mkdir /backup/
mkdir /backup/log
cp -a /etc/nginx /backup/nginx-plus-backup
cp -a /var/log/nginx /backup/log/nginx-plus-backup
mkdir -p /etc/ssl/nginx
cp nginx-repo.* /etc/ssl/nginx/
apt-get install apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring
wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor |  tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" |  tee /etc/apt/sources.list.d/nginx-plus.list
wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/modsecurity/ubuntu `lsb_release -cs` nginx-plus\n" |  tee /etc/apt/sources.list.d/nginx-modsecurity.list
apt-get update
apt-get install nginx-plus
apt-get install nginx-plus nginx-plus-module-modsecurity
mkdir /etc/nginx/modsec
cd /etc/nginx/modsec
wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
mv modsecurity.conf-recommended modsecurity.conf
mkdir -p /tmp/modsecurity/data
mkdir -p /tmp/modsecurity/tmp
mkdir -p /tmp/modsecurity/upload
mv /etc/nginx /tmp/
cd /tmp/setup/
cp -r modsecurity.d/ /etc/
cp -r nginx/ /etc/
#dpkg -i filebeat-8.10.2-amd64.deb
chown www-data /tmp/modsecurity/
chown -R www-data /tmp/modsecurity/
wget https://download.splunk.com/products/universalforwarder/releases/9.1.1/linux/splunkforwarder-9.1.1-64e843ea36b1-linux-2.6-amd64.deb
/opt/splunkforwarder/bin/splunk add forward-server 52.221.111.135:9997
/opt/splunkforwarder/bin/splunk list forward-server
/opt/splunkforwarder/bin/splunk add monitor /var/log/modsec_audit.json
