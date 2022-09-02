#!/bin/bash
# Pretty print
start="\n##############################################"
end="##############################################\n"

# Target directory
target="/home/${username}"

printf %s ${start}
printf %s "Install script for stable-diffusion + Web UI"
printf %s ${end}
# Tested on Debian 11 (Bullseye)

# Do not run as root
uid=$(id -u)
if [[ ${uid} -eq 0 ]]
then
    printf %s ${start}
    printf %s -"ERROR: This script must not be launched as root, aborting..."
    printf %s ${end}
    exit 1
fi

username=$(whoami)
printf %s ${start}
printf %s "Running on ${username} user"
printf %s ${end}

# Check if passwordless sudo
if ! sudo -l | grep -q NOPASSWD
then
    printf %s ${start}
    printf %s "${username} cannot passwordless sudo, aborting..."
    printf %s ${end}
    exit 1
fi

printf %s ${start}
printf %s "Install or upgrade mandatory packages"
printf %s ${end}
sudo apt update && sudo apt -y install curl unzip git python3 jo jpegoptim mitmproxy

printf %s ${start}
printf %s "Create and change directory to ${target}/diffusion/"
printf %s ${end}
mkdir "${target}"/diffusion
cd "${target}"/diffusion/ || { printf %s "Can't cd to ${target}/diffusion/, aborting..."; exit 1; }

printf %s ${start}
printf %s "Clone basujindal's optimized stable-diffusion fork"
printf %s ${end}
git clone https://github.com/basujindal/stable-diffusion.git

printf %s ${start}
printf %s "Clone stable-diffusion-webui"
printf %s ${end}
git clone https://github.com/orionaskatu/stable-diffusion-webui.git

printf %s ${start}
printf %s "Install or upgrade Miniconda in ~/miniconda"
printf %s ${end}
curl -s https://gist.githubusercontent.com/mherkazandjian/cce01cf3e15c0b41c1c4321245a99096/raw/03c86dae9a212446cf5b095643854f029b39c921/miniconda_installer.sh | bash -s -- ~/miniconda --upgrade

printf %s ${start}
printf %s "Create conda env and install dependencies"
printf %s ${end}
eval "$(~/miniconda/bin/conda shell.bash hook)"
conda update -n base -c defaults conda
conda env create -f stable-diffusion/environment.yaml
conda activate ldm

printf %s ${start}
printf %s "Install Web UI dependencies"
printf %s ${end}
pip install git+https://github.com/crowsonkb/k-diffusion.git
pip install git+https://github.com/TencentARC/GFPGAN.git
pip install git+https://github.com/CompVis/taming-transformers.git
pip install -r stable-diffusion-webui/requirements.txt

printf %s ${start}
printf %s "Download sd-v1-4.ckpt model"
printf %s ${end}
mkdir stable-diffusion/models/ldm/stable-diffusion-v1
wget https://ipfs.io/ipfs/bafybeicrdgunwfjxm5yr7qqe5kgybaog65wnonymaeumzkto4eagrvwz2a/stable-diffusion-v1.4-and-license.zip
unzip stable-diffusion-v1.4-and-license.zip
rm stable-diffusion-v1.4-and-license.zip
rm LICENSE.txt
printf %s ${start}
printf %s "Checking sha2456 checksum..."
printf %s ${end}
if [[ $(sha256sum sd-v1-4.ckpt | cut -d " " -f 1) != "fe4efff1e174c627256e44ec2991ba279b3816e364b49f9be2abc0b3ff3f8556" ]]
then
    printf %s ${start}
    printf %s "sd-v1-4.ckpt checksum invalid, this file is not safe !!"
    printf %s "Deleting as it can be dangerous"
    printf %s ${end}
    rm sd-v1-4.ckpt
    exit 1
fi
mv sd-v1-4.ckpt stable-diffusion/models/ldm/stable-diffusion-v1/model.ckpt

printf %s ${start}
printf %s "Download GFPGANv1.3.pth model"
printf %s ${end}
wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth -O stable-diffusion-webui/GFPGANv1.3.pth

printf %s ${start}
printf %s "Install systemd service"
printf %s ${end}
cp stable-diffusion-webui/stable-diffusion.service /etc/systemd/system/stable-diffusion.service
sed -i "s/username/${username}/g" /etc/systemd/system/stable-diffusion.service
sed -i "s/target/${target}/g" /etc/systemd/system/stable-diffusion.service
sudo systemctl enable stable-diffusion

printf %s ${start}
printf %s "Installation finished successfully!"
printf %s ${end}
