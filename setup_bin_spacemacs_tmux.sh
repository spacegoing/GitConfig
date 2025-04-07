# conda install -c conda-forge emacs
ln -s ${PWD}/spacemacs ${HOME}/.spacemacs.d
rm ${PWD}/spacemacs/init.el
git update-index --skip-worktree ${PWD}/spacemacs/init.el
ln -s ${PWD}/spacemacs/.spacemacs.clean ${PWD}/spacemacs/init.el
ln -s ${PWD}/tmux/.tmux.conf ${HOME}/.tmux.conf
mkdir ${HOME}/.config
ln -s ${PWD}/python/.config/flake8 ${HOME}/.config/flake8
ln -s ${PWD}/python/.config/yapf ${HOME}/.config/yapf
ln -s ${PWD}/python/.config/pylintrc ${HOME}/.config/pylintrc
ln -s ${PWD}/python/.config/htop ${HOME}/.config/htop

# .bin setup
ln -s ${PWD}/.bin/tmux/tat ${HOME}/bin/tat
ln -s ${PWD}/.bin/tmux/tkl ${HOME}/bin/tkl
ln -s ${PWD}/.bin/tmux/tnew ${HOME}/bin/tnew

ln -s ${PWD}/.bin/dev/pyservesg ${HOME}/bin/pyservesg
ln -s ${PWD}/.bin/dev/scpray ${HOME}/bin/scpray
ln -s ${PWD}/.bin/dev/sgpdb ${HOME}/bin/sgpdb

ln -s ${PWD}/.bin/docker/dbash ${HOME}/bin/dbash
ln -s ${PWD}/.bin/docker/drmrf ${HOME}/bin/drmrf

# manual setup
ln -s ${PWD}/.bin/tmux/tsgs/tsg ${HOME}/bin/tsg

# python setup
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
conda config --set show_channel_urls yes



# >>> Configs starts from here <<<
export LANG=en_US.UTF-8
# >>> Configs ends here <<<

# >>> my alias starts from here <<<
alias di="docker images"
alias dps="docker ps"
alias dpsa="docker ps -a"
drmc() { docker stop "$1" && docker rm -v "$1"; }
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

############################################ BCE #################################
function enableProxy(){
  export http_proxy=http://10.16.0.38:18000
  export https_proxy=http://10.16.0.38:18000
}
function disableProxy(){
  unset http_proxy https_proxy
}
