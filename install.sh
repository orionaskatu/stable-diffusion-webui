#!/bin/bash
# Pretty print
delimiter="\n##############################################\n"

# Target directory without trailing slash
if [[ -z ${1} ]]
then
    target="/home/${username}"
else
    target="${1}"
fi

printf ${delimiter}
printf "Install script for stable-diffusion + Web UI"
printf ${delimiter}
# Tested on Debian 11 (Bullseye)

# Do not run as root
uid=$(id -u)
if [[ ${uid} -eq 0 ]]
then
    printf ${delimiter}
    printf -"ERROR: This script must not be launched as root, aborting..."
    printf ${delimiter}
    exit 1
fi

username=$(whoami)
printf ${delimiter}
printf "Running on ${username} user"
printf ${delimiter}

# Check if passwordless sudo
if ! sudo -l | grep -q NOPASSWD
then
    printf ${delimiter}
    printf "${username} cannot passwordless sudo, aborting..."
    printf ${delimiter}
    exit 1
fi

printf ${delimiter}
printf "Install or upgrade mandatory packages"
printf ${delimiter}
sudo apt update && sudo apt -y install curl unzip git python3 python3-pip jo jpegoptim mitmproxy

printf ${delimiter}
printf "Create and change directory to ${target}/diffusion/"
printf ${delimiter}
mkdir "${target}"/diffusion
cd "${target}"/diffusion/ || { printf "Can't cd to ${target}/diffusion/, aborting..."; exit 1; }

printf ${delimiter}
printf "Clone basujindal's optimized stable-diffusion fork"
printf ${delimiter}
git clone https://github.com/basujindal/stable-diffusion.git

printf ${delimiter}
printf "Clone stable-diffusion-webui"
printf ${delimiter}
git clone https://github.com/orionaskatu/stable-diffusion-webui.git

printf ${delimiter}
printf "Install or upgrade Miniconda in ~/miniconda"
printf ${delimiter}
curl -s https://gist.githubusercontent.com/mherkazandjian/cce01cf3e15c0b41c1c4321245a99096/raw/03c86dae9a212446cf5b095643854f029b39c921/miniconda_installer.sh | bash -s -- "${target}"/miniconda --upgrade

printf ${delimiter}
printf "Create conda env and install dependencies"
printf ${delimiter}
eval "$(~/miniconda/bin/conda shell.bash hook)"
conda update -y -n base -c defaults conda
conda env create -f stable-diffusion/environment.yaml
conda activate ldm

printf ${delimiter}
printf "Install Web UI dependencies"
printf ${delimiter}
pip install git+https://github.com/crowsonkb/k-diffusion.git
pip install git+https://github.com/TencentARC/GFPGAN.git
pip install git+https://github.com/CompVis/taming-transformers.git
pip install -r stable-diffusion-webui/requirements.txt

printf ${delimiter}
printf "Download sd-v1-4.ckpt model"
printf ${delimiter}
mkdir stable-diffusion/models/ldm/stable-diffusion-v1
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
    printf "sd-v1-4.ckpt checksum invalid, this file is not safe !!"
    printf "Deleting as it can be dangerous"
    printf ${delimiter}
    rm sd-v1-4.ckpt
    exit 1
fi
mv sd-v1-4.ckpt stable-diffusion/models/ldm/stable-diffusion-v1/model.ckpt

printf ${delimiter}
printf "Download GFPGANv1.3.pth model"
printf ${delimiter}
wget -c https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth -O stable-diffusion-webui/GFPGANv1.3.pth

printf ${delimiter}
printf "Install systemd service"
printf ${delimiter}
cp stable-diffusion-webui/stable-diffusion.service /etc/systemd/system/stable-diffusion.service
sed -i "s/username/${username}/g" /etc/systemd/system/stable-diffusion.service
sed -i "s/target/${target}/g" /etc/systemd/system/stable-diffusion.service
sudo systemctl daemon-reload
sudo systemctl enable stable-diffusion

printf ${delimiter}
printf "Installation finished successfully!"
printf ${delimiter}
