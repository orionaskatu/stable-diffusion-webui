#!/bin/bash
# Install script for stable-diffusion + Web UI
# Tested on Debian 11 (Bullseye)

# Do not run as root
uid=$(id -u)
if [[ ${uid} -eq 0 ]]
then
    echo "This script must not be launched as root"
    exit 1
fi

username=$(whoami)
echo -e "Running on ${username} user\n"

echo -e "Install or upgrade mandatory packages\n"
sudo apt update && sudo apt -y install curl unzip git python3 jo jpegoptim mitmproxy

echo -e "Create and change directory to /home/${username}/diffusion/\n"
mkdir /home/"${username}"/diffusion
cd /home/"${username}"/diffusion/ || { echo "Can't cd to /home/${username}/diffusion/, aborting..."; exit 1; }

echo -e "Clone basujindal's optimized stable-diffusion fork\n"
git clone https://github.com/basujindal/stable-diffusion.git

echo -e "Clone stable-diffusion-webui\n"
git clone https://github.com/orionaskatu/stable-diffusion-webui.git

echo -e "Install or upgrade Miniconda in ~/miniconda\n"
curl -s https://gist.githubusercontent.com/mherkazandjian/cce01cf3e15c0b41c1c4321245a99096/raw/03c86dae9a212446cf5b095643854f029b39c921/miniconda_installer.sh | bash -s -- ~/miniconda --upgrade

echo -e "Create conda env and install dependencies\n"
eval "$(~/miniconda/bin/conda shell.bash hook)"
conda env create -f stable-diffusion/environment.yaml

echo -e "Install Web UI dependencies\n"
pip install git+https://github.com/crowsonkb/k-diffusion.git
pip install git+https://github.com/TencentARC/GFPGAN.git
pip install git+https://github.com/CompVis/taming-transformers.git
pip install -r stable-diffusion-webui/requirements.txt

echo -e "Download sd-v1-4.ckpt model\n"
mkdir stable-diffusion/models/ldm/stable-diffusion-v1
wget https://ipfs.io/ipfs/bafybeicrdgunwfjxm5yr7qqe5kgybaog65wnonymaeumzkto4eagrvwz2a/stable-diffusion-v1.4-and-license.zip
unzip stable-diffusion-v1.4-and-license.zip
rm stable-diffusion-v1.4-and-license.zip
rm LICENSE.txt
echo -e "Checking sha2456 checksum...\n"
if [[ $(sha256sum sd-v1-4.ckpt | cut -d " " -f 1) != "fe4efff1e174c627256e44ec2991ba279b3816e364b49f9be2abc0b3ff3f8556" ]]
then
    echo -e "sd-v1-4.ckpt checksum invalid, this file is not safe !!\n"
    echo -e "Deleting as it can be dangerous"
    rm sd-v1-4.ckpt
    exit 1
fi
mv sd-v1-4.ckpt stable-diffusion/models/ldm/stable-diffusion-v1/model.ckpt

echo -e "Download GFPGANv1.3.pth model\n"
wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth -O stable-diffusion-webui/GFPGANv1.3.pth

echo -e "Install systemd service\n"
cp stable-diffusion-webui/stable-diffusion.service /etc/systemd/system/stable-diffusion.service
sed -i "s/username/${username}/g" /etc/systemd/system/stable-diffusion.service
sudo systemctl enable stable-diffusion

echo -e "Installation finished successfully!\n"
