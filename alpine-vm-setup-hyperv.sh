#!/bin/sh

# Install Hyper-V integration tools
apk add hvtools

# Start necessary services
rc-service hv_fcopy_daemon start
rc-service hv_kvp_daemon start
rc-service hv_vss_daemon start

# Enable services at boot
rc-update add hv_fcopy_daemon
rc-update add hv_kvp_daemon
rc-update add hv_vss_daemon

echo "Hyper-V integration services installed and enabled successfully!"
