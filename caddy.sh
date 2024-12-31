#!/bin/bash

# Function to show usage
show_usage() {
    echo "Usage: $0 --domain <domain> --target <target_url>"
    echo "Example: $0 --domain web.api.example.com --target http://192.168.1.2:34567"
    echo ""
    echo "Options:"
    echo "  --domain    The domain name to serve (e.g., web.api.example.com)"
    echo "  --target    The target URL to proxy to (e.g., http://192.168.1.2:34567)"
    exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN="$2"
            shift
            ;;
        --target)
            TARGET="$2"
            shift
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Unknown parameter: $1"
            show_usage
            ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$DOMAIN" ] || [ -z "$TARGET" ]; then
    echo "Error: Both domain and target URL are required"
    show_usage
fi

# Validate if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check if Caddy is installed
if ! command -v caddy &> /dev/null; then
    echo "Error: Caddy is not installed"
    exit 1
fi

# Create Caddyfile configuration
echo "Creating Caddy configuration for $DOMAIN..."
cat > /etc/caddy/Caddyfile << EOF
$DOMAIN {
    reverse_proxy $TARGET
}
EOF

# Validate the configuration
echo "Validating Caddy configuration..."
if ! caddy validate --config /etc/caddy/Caddyfile; then
    echo "Error: Invalid Caddy configuration"
    exit 1
fi

# Reload Caddy
echo "Reloading Caddy service..."
if systemctl reload caddy; then
    echo "Caddy configuration has been updated successfully!"
    echo "Your site should now be available at: https://$DOMAIN"
    echo "Proxying to: $TARGET"
else
    echo "Error: Failed to reload Caddy"
