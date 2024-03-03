#!/bin/sh

USER=ubuntu
HOST=vps-28e1f96e.vps.ovh.net

git archive main --format=tar.gz -o extick.tar.gz
scp -P 2022 extick.tar.gz $USER@$HOST:/srv/extick/repo

ssh -p 2022 $USER@$HOST <<EOF
  cd /srv/extick/repo
  tar -xzf extick.tar.gz
  rm extick.tar.gz
  bash build.sh
EOF
