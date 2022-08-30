#!/bin/bash
# Needs curl & jo packages

# Discord webhook url
url="https://discord.com/api/webhooks/XXX/XXX"
# Bot username that will send the message
username="stable-diffusion"
# Cleanup unwanted characters when prompt is too long
content=$(echo ${1} | tr -d '\n();')
# Create json structure
json=$(jo username="${username}" content="${content}")
# Get escaped filename
image=$(ls ${2})

# Silently send the payload to Discord api
curl -o /dev/null -s -F "payload_json=${json}" -F "file=@\"${image}\"" "${url}"

# For debugging
#curl -F "payload_json=${json}" -F "file=@\"${image}\"" "${url}"
