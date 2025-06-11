# by CloudDras AI is your friend

### Mask domainname in git ###

# 1. create a config.sh
DOMAIN_NAME="mydomain.com"
# 2. add to .gitignore

# 3. In your scripts, source this file at the top:
#!/bin/bash
source "$(dirname "$0")/config.sh"
echo "Domain is $DOMAIN_NAME"

##############################################################

# 1. Sla de Apache VirtualHost config op als:
#    /etc/apache2/sites-available/wetty.$DOMAIN_NAME.conf

# 2. Activeer de site:
sudo a2ensite wetty.$DOMAIN_NAME.conf

# 3. Herlaad Apache om de config toe te passen:
sudo systemctl reload apache2

# 4. (Optioneel) Controleer of de site actief is:
apache2ctl -S
# Verwachte outputregel:
# port 443 namevhost wetty.$DOMAIN_NAME (/etc/apache2/sites-enabled/wetty.$DOMAIN_NAME.conf:1)

# 5. Zorg dat de backend op 192.168.1.21:3002 draait en bereikbaar is:
curl http://192.168.1.21:3002/wetty

# 6. Start Wetty met base path ondersteuning:
npx wetty --port 3002 --base /wetty --host 0.0.0.0

# Cloudflair of local DNS record indien extern benaderbaar.
# Aanmaken DNS record in local DNS wetty.$DOMAIN_NAME -> 192.168.2.111  
