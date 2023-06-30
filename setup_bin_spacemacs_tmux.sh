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
