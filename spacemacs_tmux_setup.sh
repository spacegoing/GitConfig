conda install -c conda-forge emacs
ln -s ${PWD}/spacemacs ${HOME}/.spacemacs.d
rm ${PWD}/spacemacs/init.el
ln -s ${PWD}/spacemacs/.spacemacs.clean ${PWD}/spacemacs/init.el
ln -s ${PWD}/tmux/.tmux.conf ${HOME}/.tmux.conf
