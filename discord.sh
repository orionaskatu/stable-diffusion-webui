#!/bin/bash
# Needs curl, jo and jpegoptim packages
#apt -y install curl jo jpegoptim

# Discord webhook url
url=$(cat stable-diffusion-webui/discordurl.txt)
# Bot username that will send the message
username="stable-diffusion"
# Create json structure
json=$(jo username="${username}" content="${1}")
# Get escaped filename
image=$(ls ${2})

# Reduce file size to 7,5MB (Discord's max allowed size is 8MB)
if [[ $(stat -c %s ${image}) -gt 7700000 ]]
then
    # Convert to JPG
    mogrify -format jpg ${image}
    image=${image%.png}.jpg
    # 7,5MB quiet strip all markers
    jpegoptim -S7500 -qs ${image}
fi

# Silently send the payload to Discord api
curl -o /dev/null -s --form-string "payload_json=${json}" -F "file=@\"${image}\"" "${url}"
