#!/bin/bash
source "$(dirname "$0")/config.sh"

echo "Domain is $DOMAIN_NAME"
# Use $DOMAIN_NAME wherever you need the domain

certbot certonly --manual --preferred-challenges=dns \
  -d "*.$DOMAIN_NAME" -d "$DOMAIN_NAME"
