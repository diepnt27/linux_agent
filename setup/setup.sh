mkdir /backup/
mkdir /backup/log
cp -a /etc/nginx /backup/nginx-plus-backup
cp -a /var/log/nginx /backup/log/nginx-plus-backup
mkdir -p /etc/ssl/nginx
cp nginx-repo.* /etc/ssl/nginx/
apt update
apt-get install apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring
wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor |  tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
rm -f /etc/apt/sources.list.d/
cp *.list /etc/apt/sources.list.d/
apt-get update
#apt-get install nginx-plus=32-1~focal nginx-plus-module-modsecurity=31+1.0.3-2~focal
apt-get install nginx-plus=31-1~jammy nginx-plus-module-modsecurity=31+1.0.3-2~jammy
cp -rp ModSecurity /usr/local/bin/
#sed -i '1i\load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
mkdir /etc/nginx/modsec
cd /etc/nginx/modsec
#wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
#mv modsecurity.conf-recommended modsecurity.conf
mkdir -p /tmp/modsecurity/data
mkdir -p /tmp/modsecurity/tmp
mkdir -p /tmp/modsecurity/upload
#mv /etc/nginx /tmp/
cd /tmp/setup/
cp -r modsecurity.d/ /etc/
#cp -r nginx/ /etc/
#dpkg -i filebeat-8.10.2-amd64.deb
chown www-data /tmp/modsecurity/
chown -R www-data /tmp/modsecurity/
cp /backup/nginx-plus-backup/* /etc/nginx/
cp -r /backup/nginx-plus-backup/* /etc/nginx/
nginx -t
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/conf.d/default.conf
sudo sed -i '1i load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
sudo sed -i '/gzip on;/a \    gunzip on;' /etc/nginx/nginx.conf
sudo sed -i '/listen 80;/a \    modsecurity on;\n    modsecurity_rules_file /etc/modsecurity.d/setup.conf;' $(find /etc/nginx/ -name service.conf)
if nginx -t | grep -q 'successful'; then
    sudo nginx -s stop
    sudo rm -f /run/nginx.pid
    sudo nginx
    sudo nginx -s reload
else
    echo "Nginx configuration test failed."
fi
wget -O splunkforwarder.deb https://download.splunk.com/products/universalforwarder/releases/9.1.1/linux/splunkforwarder-9.1.1-64e843ea36b1-linux-2.6-amd64.deb
sudo dpkg -i splunkforwarder.deb
/opt/splunkforwarder/bin/splunk start --accept-license
sudo /opt/splunkforwarder/bin/splunk add forward-server 52.76.100.120:9997
sudo /opt/splunkforwarder/bin/splunk list forward-server | grep '52.76.100.120:9997' > /dev/null
if [ $? -eq 0 ]; then
    echo "Successfully connected to the forward-server."
    sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/modsec_audit.json
    sudo /opt/splunkforwarder/bin/splunk start
    echo "Splunk Forwarder service has been restarted."
else
    echo "Failed to connect to the forward-server."
fi
