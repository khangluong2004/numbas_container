#!/bin/bash
set -e

apt update
apt install -y nginx git-core mysql-server \
mysql-common python3 acl libmysqlclient-dev python3-dev \
supervisor python3-pip python3-virtualenv pkg-config

groupadd numbas
useradd -m -g numbas -G www-data numbas_user

mkdir /opt/numbas_python
setfacl -dR -m g:numbas:rwx /opt/numbas_python
virtualenv -p python3 /opt/numbas_python

source /opt/numbas_python/bin/activate

service mysql start
mysql <<EOF
create database numbas_editor;
EOF

mkdir -p /srv/numbas/compiler /srv/numbas/editor /srv/numbas/media /srv/numbas/previews /srv/numbas/static
cd /srv/numbas
chmod 2770 media previews
chmod 2750 compiler static
chgrp www-data compiler media previews static
setfacl -dR -m g::rwX media previews
setfacl -dR -m g::rX compiler static

git clone https://github.com/numbas/Numbas /srv/numbas/compiler
git clone https://github.com/numbas/editor /srv/numbas/editor
pip install -r /srv/numbas/editor/requirements.txt
pip install -r /srv/numbas/compiler/requirements.txt
pip install mysqlclient gunicorn