# by CloudDras
#!/bin/bash
source "$(dirname "$0")/config.sh"

echo "Domain is $DOMAIN_NAME"
# Use $DOMAIN_NAME wherever you need the domain

# Apache Debug & Test Utility for Ubuntu
# Version 2.2 - HTTP 503 shown as DOWN in red for ProxyPass testing

# ANSI color codes
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

APACHECTL=$(command -v apachectl || command -v apache2ctl)
if [[ -z "$APACHECTL" ]]; then
  echo "apachectl or apache2ctl not found. Please install Apache."
  exit 1
fi

# Get APACHE_LOG_DIR and SUFFIX
APACHE_LOG_DIR="/var/log/apache2"
SUFFIX=""
[ -f /etc/apache2/envvars ] && {
  APACHE_LOG_DIR=$(grep '^export APACHE_LOG_DIR=' /etc/apache2/envvars | sed -E "s/.*=['\"]?([^'\"]+)['\"]?/\1/")
  SUFFIX=$(grep '^export SUFFIX=' /etc/apache2/envvars | sed -E "s/.*=['\"]?([^'\"]+)['\"]?/\1/")
}
APACHE_LOG_DIR_FULL="${APACHE_LOG_DIR}${SUFFIX}"

test_proxied_endpoints() {
  echo -e "\n${BLUE}Testing proxied websites...${NC}"
  
  while IFS= read -r -d '' conf; do
    echo -e "\n${BLUE}Checking config: $conf${NC}"
    
    # Get SSL status and port
    if grep -q 'SSLEngine on' "$conf"; then
      proto="https"
      port=443
    else
      proto="http"
      port=$(grep -m1 '<VirtualHost.*:.*>' "$conf" | grep -oP ':\K\d+' || echo "80")
    fi
    
    # Get ServerName or use hostname
    server_name=$(grep -i 'ServerName' "$conf" | awk '{print $2}')
    [ -z "$server_name" ] && server_name=$(hostname -f)
    
    # Find all ProxyPass directives (including indented)
    mapfile -t proxypass_lines < <(
      grep -hiE '^\s*ProxyPass(Match)? ' "$conf" | 
      grep -v '^\s*#' |
      awk '{$1=$1;print}'
    )
    
    for line in "${proxypass_lines[@]}"; do
      # Extract path and target
      path=$(echo "$line" | awk '{print $2}')
      target=$(echo "$line" | awk '{print $3}' | sed 's/\/$//')
      
      # Build external URL
      external_url="${proto}://${server_name}:${port}${path}"
      
      echo -e "\nTesting endpoint:"
      echo -e "  Config Directive: ${BLUE}$line${NC}"
      echo -e "  External URL: ${BLUE}$external_url${NC}"
      echo -e "  Target Server: ${BLUE}$target${NC}"
      
      # Test connection
      echo -e "\n${BLUE}Running: curl -IksSL -m 10 -H 'Host: $server_name' '$external_url'${NC}"
      response=$(curl -IksSL -m 10 -H "Host: $server_name" "$external_url" 2>&1)
      status_code=$(echo "$response" | grep -m1 'HTTP/' | awk '{print $2}')
      curl_exit=$?
      
      # Interpret results
      if [ $curl_exit -eq 0 ]; then
        if [ "$status_code" == "503" ]; then
          echo -e "${RED}DOWN: HTTP 503${NC}"
        elif [[ "$status_code" =~ ^2|3 ]]; then
          echo -e "${GREEN}SUCCESS: HTTP $status_code${NC}"
        else
          echo -e "${RED}WARNING: HTTP $status_code${NC}"
          echo "Response headers:"
          echo "$response" | head -n 10
        fi
      else
        case $curl_exit in
          7)  echo -e "${RED}ERROR: Could not connect to backend${NC}" ;;
          28) echo -e "${RED}ERROR: Connection timed out${NC}" ;;
          *)  echo -e "${RED}ERROR: Curl failed (exit code $curl_exit)${NC}" ;;
        esac
      fi
      echo "----------------------------"
    done
  done < <(find /etc/apache2/sites-available/ -name '*.conf' -print0)
}

while true; do
  echo
  echo "Apache Debug & Test Utility"
  echo "=========================="
  echo "Select an option:"
  echo " 1) Test config syntax"
  echo " 2) Show parsed virtual hosts"
  echo " 3) Show run configuration"
  echo " 4) List loaded modules"
  echo " 5) List compiled-in modules"
  echo " 6) List available directives"
  echo " 7) Show all included config files"
  echo " 8) Show Apache version"
  echo " 9) Show compile settings"
  echo "10) Start in debug mode (foreground, single worker)"
  echo "11) Start in foreground (normal)"
  echo "12) Custom apachectl command"
  echo "13) View SSL certificate details (from Apache configs)"
  echo "14) Check error log files (from Apache configs)"
  echo "15) Compare enabled and available site configs"
  echo "16) Test proxied websites (ProxyPass)"
  echo " 0) Exit"
  echo

  read -rp "Enter choice [0-16]: " CHOICE

  case $CHOICE in
    1)
      echo -e "${BLUE}Running: sudo $APACHECTL -t${NC}"
      sudo $APACHECTL -t
      ;;
    2)
      echo -e "${BLUE}Running: sudo $APACHECTL -t -D DUMP_VHOSTS${NC}"
      sudo $APACHECTL -t -D DUMP_VHOSTS
      ;;
    3)
      echo -e "${BLUE}Running: sudo $APACHECTL -t -D DUMP_RUN_CFG${NC}"
      sudo $APACHECTL -t -D DUMP_RUN_CFG
      ;;
    4)
      echo -e "${BLUE}Running: sudo $APACHECTL -M${NC}"
      sudo $APACHECTL -M
      ;;
    5)
      echo -e "${BLUE}Running: sudo $APACHECTL -l${NC}"
      sudo $APACHECTL -l
      ;;
    6)
      echo -e "${BLUE}Running: sudo $APACHECTL -L${NC}"
      sudo $APACHECTL -L
      ;;
    7)
      echo -e "${BLUE}Running: sudo $APACHECTL -t -D DUMP_INCLUDES${NC}"
      sudo $APACHECTL -t -D DUMP_INCLUDES
      ;;
    8)
      echo -e "${BLUE}Running: sudo $APACHECTL -v${NC}"
      sudo $APACHECTL -v
      ;;
    9)
      echo -e "${BLUE}Running: sudo $APACHECTL -V${NC}"
      sudo $APACHECTL -V
      ;;
    10)
      echo -e "${BLUE}Running: sudo $APACHECTL -X -e debug${NC}"
      sudo $APACHECTL -X -e debug
      ;;
    11)
      echo -e "${BLUE}Running: sudo $APACHECTL foreground${NC}"
      sudo $APACHECTL foreground
      ;;
    12)
      read -rp "Enter custom apachectl options: " CUSTOM
      echo -e "${BLUE}Running: sudo $APACHECTL $CUSTOM${NC}"
      sudo $APACHECTL $CUSTOM
      ;;
    13)
      echo
      echo -e "${BLUE}Code to be run:${NC}"
      echo -e "${BLUE}grep -hE '^\s*SSLCertificate(File|KeyFile|ChainFile)\s+' /etc/apache2/sites-available/*.conf |\\n  grep -v '^\s*#' |\\n  awk '{for(i=1;i<=NF;i++) if (\\\$i ~ /^\\//) print \\\$i;}' | sort -u${NC}"
      echo
      mapfile -t certfiles < <(
        grep -hE '^\s*SSLCertificate(File|KeyFile|ChainFile)\s+' /etc/apache2/sites-available/*.conf |
        grep -v '^\s*#' |
        awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//) print $i;}' | sort -u
      )
      if [[ ${#certfiles[@]} -eq 0 ]]; then
        echo "No certificate files found in Apache configs."
      else
        echo "Found certificate files:"
        for i in "${!certfiles[@]}"; do
          printf "%2d) %s\n" $((i+1)) "${certfiles[$i]}"
        done
        echo " 0) Cancel"
        read -rp "Select a certificate file to view details [1-${#certfiles[@]}]: " CERTSEL
        if [[ "$CERTSEL" =~ ^[0-9]+$ ]] && (( CERTSEL >= 1 && CERTSEL <= ${#certfiles[@]} )); then
          CERTPATH="${certfiles[$((CERTSEL-1))]}"
          echo -e "${BLUE}Running: sudo openssl x509 -in \"$CERTPATH\" -text -noout${NC}"
          if [[ -f "$CERTPATH" ]]; then
            echo
            sudo openssl x509 -in "$CERTPATH" -text -noout 2>/dev/null || echo "Error: Could not read certificate (may not be a public certificate file)"
          else
            echo "File not found: $CERTPATH"
          fi
        else
          echo "Cancelled or invalid selection."
        fi
      fi
      ;;
    14)
      echo
      echo -e "${BLUE}Code to be run:${NC}"
      echo -e "${BLUE}grep -hE '^\s*ErrorLog\s+' /etc/apache2/sites-available/*.conf |\\n  grep -v '^\s*#' |\\n  awk '{\\\$1=\"\"; sub(/^ +/,\"\"); print}' |\\n  sed -E \"s|\\\$\\{?APACHE_LOG_DIR\\}?|$APACHE_LOG_DIR_FULL|g\" |\\n  sed -E \"s|\\\$APACHE_LOG_DIR|$APACHE_LOG_DIR_FULL|g\" |\\n  sed \"s|^\\\"||;s|\\\"$||\" | sort -u${NC}"
      echo
      mapfile -t errorlogs < <(
        grep -hE '^\s*ErrorLog\s+' /etc/apache2/sites-available/*.conf |
        grep -v '^\s*#' |
        awk '{$1=""; sub(/^ +/,""); print}' |
        sed -E "s|\$\{?APACHE_LOG_DIR\}?|$APACHE_LOG_DIR_FULL|g" |
        sed -E "s|\$APACHE_LOG_DIR|$APACHE_LOG_DIR_FULL|g" |
        sed "s|^\"||;s|\"$||" |
        sort -u
      )
      if [[ ${#errorlogs[@]} -eq 0 ]]; then
        errorlogs+=("$APACHE_LOG_DIR_FULL/error.log")
      fi
      echo "Found error log files:"
      for i in "${!errorlogs[@]}"; do
        printf "%2d) %s\n" $((i+1)) "${errorlogs[$i]}"
      done
      echo " 0) Cancel"
      read -rp "Select an error log file to tail [1-${#errorlogs[@]}]: " LOGSEL
      if [[ "$LOGSEL" =~ ^[0-9]+$ ]] && (( LOGSEL >= 1 && LOGSEL <= ${#errorlogs[@]} )); then
        LOGPATH="${errorlogs[$((LOGSEL-1))]}"
        echo -e "${BLUE}Running: sudo tail -n 40 -f \"$LOGPATH\"${NC}"
        if [[ -f "$LOGPATH" ]]; then
          echo
          echo "Tailing last 40 lines of $LOGPATH (Ctrl+C to stop)..."
          sudo tail -n 40 -f "$LOGPATH"
        else
          echo "File not found: $LOGPATH"
        fi
      else
        echo "Cancelled or invalid selection."
      fi
      ;;
    15)
      echo
      echo -e "${BLUE}Code to be run:${NC}"
      echo -e "${BLUE}AVAILABLE=(\$(ls /etc/apache2/sites-available/*.conf | xargs -n1 basename))\\nENABLED=(\$(find /etc/apache2/sites-enabled/ -type l -name '*.conf' -exec readlink -f {} \\; | xargs -n1 basename))\\nBROKEN=(symlinks in sites-enabled that do not resolve to a file)${NC}"
      echo
      AVAILABLE=()
      ENABLED=()
      BROKEN=()
      for f in /etc/apache2/sites-available/*.conf; do
        AVAILABLE+=("$(basename "$f")")
      done
      for l in /etc/apache2/sites-enabled/*.conf; do
        if [[ -L "$l" ]]; then
          target=$(readlink -f "$l")
          ENABLED+=("$(basename "$target")")
          if [[ ! -e "$target" ]]; then
            BROKEN+=("$(basename "$l") (broken link)")
          fi
        else
          ENABLED+=("$(basename "$l")")
        fi
      done

      echo
      echo "Enabled sites:"
      for site in "${ENABLED[@]}"; do
        echo "  [ENABLED] $site"
      done
      echo
      echo "Available but not enabled:"
      for site in "${AVAILABLE[@]}"; do
        if [[ ! " ${ENABLED[*]} " =~ " $site " ]]; then
          echo "  [DISABLED] $site"
        fi
      done
      if [[ ${#BROKEN[@]} -gt 0 ]]; then
        echo
        echo "Broken symlinks in sites-enabled:"
        for site in "${BROKEN[@]}"; do
          echo "  [BROKEN] $site"
        done
      fi
      ;;
    16)
      echo -e "${BLUE}Running: Test all ProxyPass endpoints in /etc/apache2/sites-available/*.conf${NC}"
      test_proxied_endpoints
      ;;
    0) echo "Exiting." ; exit 0 ;;
    *) echo "Invalid choice." ;;
  esac

  echo
  read -rp "Press ENTER to return to the menu..."
done

