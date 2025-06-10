sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini \
  -d '*.$DOMAIN_NAME' -d $DOMAIN_NAME
