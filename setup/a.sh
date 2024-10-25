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
