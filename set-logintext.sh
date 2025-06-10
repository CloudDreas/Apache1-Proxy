#!/bin/bash

# 1. Set the server role
echo "Proxy en Mailserver" | sudo tee /etc/server-role

# 2. Create a script in /etc/profile.d/ to display the role in red
sudo tee /etc/profile.d/show-server-role.sh > /dev/null <<'EOF'
#!/bin/bash
if [ -f /etc/server-role ]; then
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    echo -e "${RED}==== SERVER ROLE: $(cat /etc/server-role) ====${NC}"
fi
EOF

# 3. Make sure the script is executable
sudo chmod +x /etc/profile.d/show-server-role.sh
