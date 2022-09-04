#!/bin/bash
# Need to source conda profile before activating
source /home/username/miniconda/etc/profile.d/conda.sh
# Activate python ldm env
conda activate ldm
# mitmproxy package needed + nopasswd sudo
sudo mitmdump -q --listen-port 80 --mode reverse:http://127.0.0.1:7860/ &
# Launch WebUI with parameters
python -u stable-diffusion-webui/webui.py --no-progressbar-hiding --max-batch-count 30 --medvram --allow-code
