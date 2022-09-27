#!/bin/bash
# mitmproxy package needed + nopasswd sudo
sudo mitmdump -q --listen-port 80 --mode reverse:http://127.0.0.1:7860/ &
# Launch WebUI with parameters
./webui.sh
