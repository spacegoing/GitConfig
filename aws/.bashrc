#export HF_ENDPOINT=https://hf-mirror.com
# >>> Configs starts from here <<<
export LANG=en_US.UTF-8
# >>> Configs ends here <<<

# >>> my alias starts from here <<<
alias di="docker images"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias drm="docker rm -f"
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
alias dli="docker login --username=lichang93 ccr-2bm70y8h-vpc.cnc.bj.baidubce.com"
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




# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/fsx/ubuntu/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/fsx/ubuntu/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/fsx/ubuntu/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/fsx/ubuntu/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PDSH_RCMD_TYPE=ssh
export WCOLL=${HOME}/hostfile
export PDSH_SSH_ARGS_APPEND="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
alias genhf="scontrol show hostnames $(sinfo -h -p dev -o "%N") > ~/hostfile"
alias pdown="pdsh 'docker rm -f verldev'"

rayup() {
  ip=$(hostname -I | awk '{print $1}')
  docker exec verldev bash -c '. /root/.venv/base/bin/activate && ray start --head' && \
  pdsh -x $(hostname) "docker exec verldev bash -c '. /root/.venv/base/bin/activate && ray start --address=${ip}:6379'"
}

orayup() {
  ip=$(hostname -I | awk '{print $1}')
  docker exec verldev bash -c 'ray start --head' && \
  pdsh -x $(hostname) "docker exec verldev bash -c 'ray start --address=${ip}:6379'"
}

raydown() {
  docker exec verldev bash -c '. /root/.venv/base/bin/activate && ray stop' && \
  pdsh -x $(hostname) "docker exec verldev bash -c '. /root/.venv/base/bin/activate && ray stop'"
}

ppull() {
	local image="${1:-spacegoing/myverl:awsefa}"
	pdsh "docker pull $image"
}

pup() {
	local image="${1:-spacegoing/myverl:awsefa}"
	pdsh "docker run --ipc=host --privileged --name verldev --gpus all --network=host --shm-size=1800gb -itd \
		-v /fsx/ubuntu/public:/root/myCodeLab/public \
		-v /opt/dlami/nvme/tmp_ray:/tmp \
		$image"
}

conda activate grandsa
