# conda install -c conda-forge emacs
ln -s ${PWD}/spacemacs ${HOME}/.spacemacs.d
rm ${PWD}/spacemacs/init.el
ln -s ${PWD}/spacemacs/.spacemacs.clean ${PWD}/spacemacs/init.el
ln -s ${PWD}/tmux/.tmux.conf ${HOME}/.tmux.conf
mkdir ${HOME}/.config
ln -s ${PWD}/python/.config/flake8 ${HOME}/.config/flake8
ln -s ${PWD}/python/.config/yapf ${HOME}/.config/yapf
ln -s ${PWD}/python/.config/pylintrc ${HOME}/.config/pylintrc
ln -s ${PWD}/python/.config/htop ${HOME}/.config/htop

# .bin setup
ln -s ${PWD}/.bin/tmux/tat ${HOME}/bin/tmux/tat
ln -s ${PWD}/.bin/tmux/tkl ${HOME}/bin/tmux/tkl
ln -s ${PWD}/.bin/tmux/tnew ${HOME}/bin/tmux/tnew

ln -s ${PWD}/.bin/dev/pyservesg ${HOME}/bin/dev/pyservesg
ln -s ${PWD}/.bin/dev/scpray ${HOME}/bin/dev/scpray

ln -s ${PWD}/.bin/docker/dbash ${HOME}/bin/docker/dbash
ln -s ${PWD}/.bin/docker/drmrf ${HOME}/bin/docker/drmrf

# manual setup
ln -s ${PWD}/.bin/tmux/tsgs/tsg ${HOME}/bin/tmux/tsgs/tsg
