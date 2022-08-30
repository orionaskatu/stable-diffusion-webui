#!/bin/bash
# Need to source conda profile before activating
source ~/anaconda3/etc/profile.d/conda.sh
# Activate python ldm env
conda activate ldm
# Launch from stable-diffusion root folder
cd ../
# mitmproxy package needed
sudo mitmdump -q --listen-port 80 --mode reverse:http://127.0.0.1:7860/ &
# Auto relauncher
python scripts/relauncher.py
