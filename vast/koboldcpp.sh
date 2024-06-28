#!/bin/bash

set -xe

MODEL_URL="https://huggingface.co/mradermacher/Midnight-Miqu-70B-v1.5-i1-GGUF/resolve/main/Midnight-Miqu-70B-v1.5.i1-Q4_K_S.gguf?download=true"
#MODEL_URL="https://huggingface.co/dranger003/c4ai-command-r-plus-iMat.GGUF/resolve/main/ggml-c4ai-command-r-plus-q4_k_s-00001-of-00002.gguf?download=true"
GPU_LAYERS=99
CONTEXT_SIZE=16000

# Install aria2c
apt update
apt install aria2 -y

# Install cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb

# Download model
aria2c -x 10 -o model.gguf --summary-interval=5 --download-result=default --file-allocation=none "$MODEL_URL"

# Download Kobold
curl -fLo /usr/bin/koboldcpp https://koboldai.org/cpplinux
chmod +x /usr/bin/koboldcpp

# Run Kobold
koboldcpp model.gguf \
  --usecublas --multiuser --gpulayers $GPU_LAYERS --contextsize $CONTEXT_SIZE \
  --flashattention --quantkv 1

# cloudflared tunnel --url http://127.0.0.1:5001 --protocol http2
