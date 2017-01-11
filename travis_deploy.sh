#!/bin/bash

set -e

SHA=`git rev-parse --short --verify HEAD`

git config user.name "$COMMIT_AUTHOR"
git config user.email "$COMMIT_AUTHOR_EMAIL"
git checkout --orphan gh-pages
git rm --cached -r .
echo "# Automatic build" > README.md
echo "Built pdf from \`$SHA\`. See https://github.com/ethereum/yellowpaper/ for details." >> README.md
mv Paper.pdf paper.pdf
git add -f paper.pdf
git commit -m "Built pdf from {$SHA}."

ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploykey.enc -out deploykey -d
chmod 600 deploykey
eval `ssh-agent -s`
ssh-add deploykey

git push -f "$PUSH_REPO" gh-pages
