#!/bin/bash
# >>> Configs starts from here <<<
export LANG=en_US.UTF-8
# >>> Configs ends here <<<

# >>> my alias starts from here <<<
alias di="docker images"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias drm='docker rm -f'
alias drmiall="docker rmi $(docker images -f "dangling=true" -q)"
alias drmall="docker rm -f $(docker ps -aq)"
alias drmv="docker volume prune"
dbash() { docker exec -it "$1" bash; }
alias dcu="docker compose up -d"
alias dcugpu="docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d"
alias dcd="docker compose down"
alias dcdrmv="docker compose down --volumes"
alias dcps="docker compose ps"
alias dclogs="docker compose logs"
alias gitr="git pull origin master"
tnew() { tmux new -s "$1"; }
tat() { tmux a -t "$1"; }
tkl() { tmux kill-session -t "$1"; }
# >>> my alias ends here <<<

# >>> my functions starts from here <<<
dil() {
    for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
        commit_label=$(docker inspect --format "{{ index .Config.Labels \"commit\" }}" $image)
        if [ ! -z "$commit_label" ]; then
            echo "$image: $commit_label"
        fi
    done
}
# >>> my functions ends here <<<

alias alin="docker login --username=63907871@qq.com registry.cn-hangzhou.aliyuncs.com"
alias dkin="docker login --username=spacebnbk@gmail.com"



# Old -----------------------------
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



