#!/bin/bash

# Arguments
REPO_PATH=$1
BRANCH_NAME=$2

# Navigate to the repository
cd "$REPO_PATH" || exit

# Run git filter-repo with the commit callback
git filter-repo \
    --refs "$BRANCH_NAME" \
    --commit-callback '
uname = b"xxx"
email = b"xxx@jd.com"
commit.author_name, commit.author_email = uname, email
commit.committer_name, commit.committer_email = uname, email
message = commit.message
idx = message.find(b"Signed-off-by:")
if idx != -1:
    message = message[:idx]
message += b"Signed-off-by: xxx <xxx@jd.com>\r\n"
commit.message = message
' \
    --force
