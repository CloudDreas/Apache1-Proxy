</small>
# by CloudDras AI is your friend

---
**For testing**


**Mask your domain name in scripts before uploading to Git**

1. **Create a `config.sh` file** in your project directory:
    ```
    DOMAIN_NAME="mydomain.com"
    ```

2. **Add `config.sh` to your `.gitignore`:**
    ```
    config.sh
    ```

3. **In each script, source `config.sh` at the top:**
    ```
    #!/bin/bash
    source "$(dirname "$0")/config.sh"
    echo "Domain is $DOMAIN_NAME"
    ```

---

**Example: Apache VirtualHost Setup with Masked Domain**

1. Save your Apache VirtualHost config as:  
   `/etc/apache2/sites-available/wetty.$DOMAIN_NAME.conf`

2. Enable the site:
    ```
    sudo a2ensite wetty.$DOMAIN_NAME.conf
    ```

3. Reload Apache to apply the config:
    ```
    sudo systemctl reload apache2
    ```

4. (Optional) Check if the site is active:
    ```
    apache2ctl -S
    # Expected output:
    # port 443 namevhost wetty.$DOMAIN_NAME (/etc/apache2/sites-enabled/wetty.$DOMAIN_NAME.conf:1)
    ```

5. Ensure the backend is running and reachable:
    ```
    curl http://192.168.1.21:3002/wetty
    ```

6. Start Wetty with base path support:
    ```
    npx wetty --port 3002 --base /wetty --host 0.0.0.0
    ```

7. (If externally accessible)  
   Create a DNS record in your local DNS:  
   `wetty.$DOMAIN_NAME → 192.168.2.111`

---

**Notes:**
- Never commit your real domain or sensitive data to public repositories.
- Provide a `config.sample.sh` with a placeholder domain for others to copy and customize.
- For any questions or improvements, feel free to open an issue or pull request.

---

*Happy automating!*
</small>
