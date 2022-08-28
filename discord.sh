#!/bin/bash
# Needs curl & jo packages

# Discord webhook url
url="https://discord.com/api/webhooks/XXX/XXX"
# Bot username that will send the message
username="stable-diffusion"
# Create json structure
json=$(jo username="${username}" content="${1}")
# Get escaped filename
image=$(ls ${2})

curl -o /dev/null -s -F "payload_json=${json}" -F "file=@\"${image}\"" "${url}"
