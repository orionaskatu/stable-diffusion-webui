#!/bin/bash
# Pretty print
delimiter="\n#######################################################\n"

printf ${delimiter}
printf "Install script for packages and systemd service\n"
printf "Tested on Debian 11 (Bullseye)"
printf ${delimiter}

# Do not run as root
uid=$(id -u)
if [[ ${uid} -eq 0 ]]
then
    printf ${delimiter}
    printf "\x1B[31mERROR: This script must not be launched as root, aborting...\e[0m"
    printf ${delimiter}
    exit 1
fi

username=$(whoami)
printf ${delimiter}
printf "Running on \x1B[32m${username}\e[0m user"
printf ${delimiter}

# Target directory without trailing slash
if [[ -z ${1} ]]
then
    target="/home/${username}"
else
    target="${1}"
fi
printf ${delimiter}
printf "Target directory will be : \x1B[32m${target}/\e[0m"
printf ${delimiter}

# Check if passwordless sudo
if ! sudo -l | grep -q NOPASSWD
then
    printf ${delimiter}
    printf "\x1B[31mERROR: ${username} cannot passwordless sudo, aborting...\e[0m"
    printf ${delimiter}
    exit 1
fi

printf ${delimiter}
printf "Install or upgrade mandatory packages"
printf ${delimiter}
sudo apt update && sudo apt -y install curl git python3 python3-pip python3-venv imagemagick jo jpegoptim mitmproxy

printf ${delimiter}
printf "Install systemd service"
printf ${delimiter}
sudo cp stable-diffusion.service /etc/systemd/system/stable-diffusion.service
sudo sed -i "s/username/${username}/g" /etc/systemd/system/stable-diffusion.service
sudo sed -i "s|sdtarget|${target}|g" /etc/systemd/system/stable-diffusion.service
sudo systemctl daemon-reload
sudo systemctl enable stable-diffusion
sudo systemctl start stable-diffusion

printf ${delimiter}
printf "Installation successful!"
printf ${delimiter}
