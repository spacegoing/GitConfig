#!/bin/bash

## Github clone
git config --global url."https://gitclone.com/".insteadOf https://

## Conda
filepath="$HOME/.condarc"
# Check if the file exists, if so delete it
if [ -f "$filepath" ]; then
  rm "$filepath"
fi
# Create a new .condarc file and write the settings into it
cat > "$filepath" << EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  deepmodeling: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/
EOF
conda clean -i

## pip
# tmp usage
# pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple


# Homebrew
# https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
# Linux
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/



