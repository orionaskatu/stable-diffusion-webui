#!/bin/bash
# Pretty print
delimiter="\n#######################################################\n"

printf ${delimiter}
printf "Update script for stable-diffusion + Web UI\n"
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
printf "Stop stable-diffusion"
printf ${delimiter}
sudo systemctl stop stable-diffusion

printf ${delimiter}
printf "Upgrade mandatory packages"
printf ${delimiter}
sudo apt update && sudo apt -y install curl unzip git python3 python3-pip imagemagick jo jpegoptim mitmproxy

printf ${delimiter}
printf "Update basujindal's optimized stable-diffusion fork"
printf ${delimiter}
cd "${target}"/diffusion/stable-diffusion || { printf "\x1B[31mERROR: Can't cd to ${target}/diffusion/stable-diffusion, aborting...\e[0m"; exit 1; }
git pull

printf ${delimiter}
printf "Update taming-transformers"
printf ${delimiter}
cd "${target}"/diffusion/taming-transformers/ || { printf "\x1B[31mERROR: Can't cd to ${target}/diffusion/taming-transformers/, aborting...\e[0m"; exit 1; }
git pull

printf ${delimiter}
printf "Update stable-diffusion-webui"
printf ${delimiter}
cd "${target}"/diffusion/stable-diffusion/stable-diffusion-webui || { printf "\x1B[31mERROR: Can't cd to ${target}/diffusion/stable-diffusion/stable-diffusion-webui, aborting...\e[0m"; exit 1; }
git pull

printf ${delimiter}
printf "Install or upgrade Miniconda in \x1B[32m/home/${username}/miniconda\e[0m"
printf ${delimiter}
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/"${username}"/miniconda
rm Miniconda3-latest-Linux-x86_64.sh

printf ${delimiter}
printf "Update conda env and dependencies"
printf ${delimiter}
source /home/"${username}"/miniconda/etc/profile.d/conda.sh
conda update -y -n base -c defaults conda
conda env update -f environment.yaml
conda activate ldm

printf ${delimiter}
printf "Update Web UI dependencies"
printf ${delimiter}
pip install git+https://github.com/crowsonkb/k-diffusion.git
pip install git+https://github.com/TencentARC/GFPGAN.git
pip install git+https://github.com/CompVis/taming-transformers.git
pip install -r stable-diffusion-webui/requirements_versions.txt

printf ${delimiter}
printf "Start stable-diffusion"
printf ${delimiter}
chmod +x stable-diffusion-webui/start.sh
sed -i "s/username/${username}/g" stable-diffusion-webui/start.sh
sudo systemctl start stable-diffusion

printf ${delimiter}
printf "Installation successful!"
printf ${delimiter}
