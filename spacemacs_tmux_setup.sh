# conda install -c conda-forge emacs
ln -s ${PWD}/spacemacs ${HOME}/.spacemacs.d
rm ${PWD}/spacemacs/init.el
ln -s ${PWD}/spacemacs/.spacemacs.clean ${PWD}/spacemacs/init.el
ln -s ${PWD}/tmux/.tmux.conf ${HOME}/.tmux.conf
mkdir ${HOME}/.config
ln -s ${PWD}/python/.config/flake8 ${HOME}/.config/flake8
ln -s ${PWD}/python/.config/yapf ${HOME}/.config/yapf
ln -s ${PWD}/python/.config/pylintrc ${HOME}/.config/pylintrc

