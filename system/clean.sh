docker-compose down
rm -rf public-proxy/
cp -rp backup/public-proxy/ .
chmod +x public-proxy/runtime/endpoint.sh
bash autosetup.sh
