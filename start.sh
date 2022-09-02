#!/bin/bash
# Need to source conda profile before activating
source sdtarget/miniconda/etc/profile.d/conda.sh
# Activate python ldm env
conda activate ldm
# mitmproxy package needed + nopasswd sudo
sudo mitmdump -q --listen-port 80 --mode reverse:http://127.0.0.1:7860/ &
# Launch WebUI with parameters
python stable-diffusion-webui/webui.py --no-progressbar-hiding --max-batch-count 30 --lowvram --always-batch-cond-uncond --allow-code
