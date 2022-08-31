#!/bin/bash
# Needs curl, jo and jpegoptim packages
#apt -y install curl jo jpegoptim

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

# Reduce file size to 7,5MB (Discord's max allowed size is 8MB)
if [[ $(stat -c %s ${image}) -gt 7700000 ]]
then
    # 8MB quiet strip all markers
    jpegoptim -S7500 -qs ${image}
fi


# Silently send the payload to Discord api
curl -o /dev/null -s -F "payload_json=${json}" -F "file=@\"${image}\"" "${url}"

# For debugging
#curl -F "payload_json=${json}" -F "file=@\"${image}\"" "${url}"
