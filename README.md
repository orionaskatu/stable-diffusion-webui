# Prequisites

**It is NOT SAFE to expose this implementation of the Web UI outside your local network (mainly because of passwordless sudo).**

**I'm not a developer and my code is far from good, so you WILL encounter bugs.**

Tested on Debian 11 (Bullseye), it may need adjustments for other Linux distros.

You just need `python3` and the `proprietary nvidia drivers`.

For installation and reverse proxy on port 80 you need to sudo without password (in `/etc/sudoers.d/username`):
```commmandline
username   ALL=(ALL) NOPASSWD: ALL
```

Easy install script:
`bash <(wget -qO- https://raw.githubusercontent.com/orionaskatu/stable-diffusion-webui/master/install.sh)`


The default installation directory for stable-diffusion is `/home/$username/diffusion`.

Miniconda will be installed in `/home/$username/miniconda`.

If you want to install stable-diffusion somewhere else, just put the path in parameter (without trailing slash) like: `bash install.sh /opt`, it will be installed in a subdirectory named `diffusion`.


## Features

A bash script `install.sh` that:
 - Installs all system dependencies
 - Installs stable-diffusion + WebUI
 - Installs Miniconda and all python dependencies
 - Downloads the sd-v1-4.ckpt model
 - Downloads the GFPGANv1.3.pth model
 - Creates a systemd service to easily control stable-diffusion

A bash script `update.sh` that:
  - Updates all system packages
  - Updates all github sources
  - Updates all python dependencies

A bash script `start.sh` that:
 - Activates `ldm` conda env
 - Launches a reverse proxy on port 80 to easily access the webui from the local network
 - Launches `webui.py` with these params: `--no-progressbar-hiding --max-batch-count 30 --medvram --opt-split-attention --allow-code`

A System tab with buttons to:
 - Read the last 20 lines of `journalctl -u stable-diffusion`
 - Print `nvidia-smi` output
 - Purge `outputs` directory
 - Update stable-diffusion and the WebUI
 - Restart the WebUI (useful in case of OOM)
 - Power off the system

A bash script `discord.sh` to send generation infos + images to discord via webhook.
It also sends status changes on start/update/reboot/stop.

It converts and compress to jpg if the file is too big for Discord (8MB limit).

You have to put your Discord webhook url in a `discordurl.txt` file in the same directory as the `discord.sh` file :
`https://discord.com/api/webhooks/xxx/xxx`

Scrolls to output after clicking on `Generate` buttons (useful for mobile usage or small screens).

Start/stop is controlled by systemd `/etc/systemd/system/stable-diffusion.service` and set to start at boot.

 ## TODO

 Next planned features:
  - Make a non-customized and more portable version that can be proposed to the original repo


↓↓↓↓ ORIGINAL README BELOW ↓↓↓↓

---
---


# Stable Diffusion web UI
A browser interface based on Gradio library for Stable Diffusion.

![](txt2img_Screenshot.png)

## Features
[Detailed feature showcase with images](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Features):
- Original txt2img and img2img modes
- One click install and run script (but you still must install python and git)
- Outpainting
- Inpainting
- Prompt matrix
- Stable Diffusion upscale
- Attention
- Loopback
- X/Y plot
- Textual Inversion
- Extras tab with:
    - GFPGAN, neural network that fixes faces
    - CodeFormer, face restoration tool as an alternative to GFPGAN
    - RealESRGAN, neural network upscaler
    - ESRGAN, neural network with a lot of third party models
    - SwinIR, neural network upscaler
    - LDSR, Latent diffusion super resolution upscaling
- Resizing aspect ratio options
- Sampling method selection
- Interrupt processing at any time
- 4GB video card support
- Correct seeds for batches
- Prompt length validation
- Generation parameters added as text to PNG
- Tab to view an existing picture's generation parameters
- Settings page
- Running custom code from UI
- Mouseover hints for most UI elements
- Possible to change defaults/mix/max/step values for UI elements via text config
- Random artist button
- Tiling support: UI checkbox to create images that can be tiled like textures
- Progress bar and live image generation preview
- Negative prompt
- Styles
- Variations
- Seed resizing
- CLIP interrogator
- Prompt Editing
- Batch Processing
- Img2img Alternative
- Highres Fix
- LDSR Upscaling

## Installation and Running
Make sure the required [dependencies](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Dependencies) are met and follow the instructions available for both [NVidia](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Install-and-Run-on-NVidia-GPUs) (recommended) and [AMD](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Install-and-Run-on-AMD-GPUs) GPUs.

Alternatively, use Google Colab:

- [Colab, maintained by Akaibu](https://colab.research.google.com/drive/1kw3egmSn-KgWsikYvOMjJkVDsPLjEMzl)
- [Colab, original by me, outdated](https://colab.research.google.com/drive/1Iy-xW9t1-OQWhb0hNxueGij8phCyluOh).

### Automatic Installation on Windows
1. Install [Python 3.10.6](https://www.python.org/downloads/windows/), checking "Add Python to PATH"
2. Install [git](https://git-scm.com/download/win).
3. Download the stable-diffusion-webui repository, for example by running `git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git`.
4. Place `model.ckpt` in the `models` directory (see [dependencies](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Dependencies) for where to get it).
5. _*(Optional)*_ Place `GFPGANv1.4.pth` in the base directory, alongside `webui.py` (see [dependencies](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Dependencies) for where to get it).
6. Run `webui-user.bat` from Windows Explorer as normal, non-administrator, user.

### Automatic Installation on Linux
1. Install the dependencies:
```bash
# Debian-based:
sudo apt install wget git python3 python3-venv
# Red Hat-based:
sudo dnf install wget git python3
# Arch-based:
sudo pacman -S wget git python3
```
2. To install in `/home/$(whoami)/stable-diffusion-webui/`, run:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh)
```

### Installation on Apple Silicon

Find the instructions [here](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Installation-on-Apple-Silicon).

## Documentation
The documentation was moved from this README over to the project's [wiki](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki).

## Credits
- Stable Diffusion - https://github.com/CompVis/stable-diffusion, https://github.com/CompVis/taming-transformers
- k-diffusion - https://github.com/crowsonkb/k-diffusion.git
- GFPGAN - https://github.com/TencentARC/GFPGAN.git
- CodeFormer - https://github.com/sczhou/CodeFormer
- ESRGAN - https://github.com/xinntao/ESRGAN
- SwinIR - https://github.com/JingyunLiang/SwinIR
- LDSR - https://github.com/Hafiidz/latent-diffusion
- Ideas for optimizations - https://github.com/basujindal/stable-diffusion
- Doggettx - Cross Attention layer optimization - https://github.com/Doggettx/stable-diffusion, original idea for prompt editing.
- Idea for SD upscale - https://github.com/jquesnelle/txt2imghd
- Noise generation for outpainting mk2 - https://github.com/parlance-zz/g-diffuser-bot
- CLIP interrogator idea and borrowing some code - https://github.com/pharmapsychotic/clip-interrogator
- Initial Gradio script - posted on 4chan by an Anonymous user. Thank you Anonymous user.
- (You)
