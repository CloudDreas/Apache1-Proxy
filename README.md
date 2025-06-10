```bash
# 1. Sla de Apache VirtualHost config op als:
#    /etc/apache2/sites-available/wetty.vanwaverentech.nl.conf

# 2. Activeer de site:
sudo a2ensite wetty.vanwaverentech.nl.conf

# 3. Herlaad Apache om de config toe te passen:
sudo systemctl reload apache2

# 4. (Optioneel) Controleer of de site actief is:
apache2ctl -S
# Verwachte outputregel:
# port 443 namevhost wetty.vanwaverentech.nl (/etc/apache2/sites-enabled/wetty.vanwaverentech.nl.conf:1)

# 5. Zorg dat de backend op 192.168.1.21:3002 draait en bereikbaar is:
curl http://192.168.1.21:3002/wetty

# 6. Start Wetty met base path ondersteuning:
npx wetty --port 3002 --base /wetty --host 0.0.0.0

# Cloudflair of local DNS record indien extern benaderbaar.
# Aanmaken DNS record in local DNS wetty.vanwaverentech.nl -> 192.168.2.111  
