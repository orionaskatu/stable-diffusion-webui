#!/bin/bash
# Pretty print
delimiter="\n#######################################################\n"

printf ${delimiter}
printf "Install script for stable-diffusion + Web UI\n"
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
sudo apt update && sudo apt -y install curl unzip git python3 python3-pip imagemagick jo jpegoptim mitmproxy
sudo apt install at --no-install-recommends

printf ${delimiter}
printf "Create and change directory to \x1B[32m${target}/diffusion/\e[0m"
printf ${delimiter}
mkdir "${target}"/diffusion
cd "${target}"/diffusion/ || { printf "\x1B[31mERROR: Can't cd to ${target}/diffusion/, aborting...\e[0m"; exit 1; }

printf ${delimiter}
printf "Clone basujindal's optimized stable-diffusion fork"
printf ${delimiter}
git clone https://github.com/basujindal/stable-diffusion.git

printf ${delimiter}
printf "Clone taming-transformers"
printf ${delimiter}
git clone https://github.com/CompVis/taming-transformers.git

printf ${delimiter}
printf "Clone CodeFormer"
printf ${delimiter}
git clone https://github.com/sczhou/CodeFormer.git

printf ${delimiter}
printf "Clone stable-diffusion-webui"
printf ${delimiter}
cd "${target}"/diffusion/stable-diffusion/ || { printf "\x1B[31mERROR: Can't cd to ${target}/diffusion/stable-diffusion/, aborting...\e[0m"; exit 1; }
git clone https://github.com/orionaskatu/stable-diffusion-webui.git

printf ${delimiter}
printf "Install or upgrade Miniconda in \x1B[32m/home/${username}/miniconda\e[0m"
printf ${delimiter}
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/"${username}"/miniconda
rm Miniconda3-latest-Linux-x86_64.sh

printf ${delimiter}
printf "Create conda env and install dependencies"
printf ${delimiter}
/home/"${username}"/miniconda/bin/conda init bash
source /home/"${username}"/miniconda/etc/profile.d/conda.sh
conda update -y -n base -c defaults conda
conda env create -f environment.yaml
conda activate ldm

printf ${delimiter}
printf "Install Web UI dependencies"
printf ${delimiter}
pip install -r stable-diffusion-webui/requirements_versions.txt
pip install -r ../CodeFormer/requirements.txt --prefer-binary

printf ${delimiter}
printf "Download sd-v1-4.ckpt model"
printf ${delimiter}
wget -c https://ipfs.io/ipfs/bafybeicrdgunwfjxm5yr7qqe5kgybaog65wnonymaeumzkto4eagrvwz2a/stable-diffusion-v1.4-and-license.zip
unzip stable-diffusion-v1.4-and-license.zip
rm stable-diffusion-v1.4-and-license.zip
rm LICENSE.txt
printf ${delimiter}
printf "Checking sha2456 checksum..."
printf ${delimiter}
if [[ $(sha256sum sd-v1-4.ckpt | cut -d " " -f 1) != "fe4efff1e174c627256e44ec2991ba279b3816e364b49f9be2abc0b3ff3f8556" ]]
then
    printf ${delimiter}
    printf "\x1B[31mERROR: sd-v1-4.ckpt checksum invalid, this file is not safe !!\e[0m"
    printf "\x1B[31mDeleting as it can be dangerous\e[0m"
    printf ${delimiter}
    rm sd-v1-4.ckpt
    exit 1
fi
mkdir models/ldm/stable-diffusion-v1
mv sd-v1-4.ckpt models/ldm/stable-diffusion-v1/model.ckpt

printf ${delimiter}
printf "Download GFPGANv1.3.pth model"
printf ${delimiter}
wget -c https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth -O stable-diffusion-webui/GFPGANv1.3.pth

printf ${delimiter}
printf "Copy config.json"
printf ${delimiter}
cp stable-diffusion-webui/config.json .
echo "${target}" > "${target}"/diffusion/stable-diffusion/stable-diffusion-webui/target

printf ${delimiter}
printf "Install systemd service"
printf ${delimiter}
sudo cp stable-diffusion-webui/stable-diffusion.service /etc/systemd/system/stable-diffusion.service
sudo sed -i "s/username/${username}/g" /etc/systemd/system/stable-diffusion.service
sudo sed -i "s|sdtarget|${target}|g" /etc/systemd/system/stable-diffusion.service
sudo systemctl daemon-reload
sudo systemctl enable stable-diffusion
sudo systemctl start stable-diffusion

printf ${delimiter}
printf "Installation successful!"
printf ${delimiter}
