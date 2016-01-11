git config --global alias.cm commit
git config --global alias.cmm "commit -m" # With message
git config --global alias.cfm "commit -a -m" # Skip staging, commit all modified tracked files with messages.

git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.unstage 'reset HEAD'
git config --global alias.last 'log -1 HEAD'
