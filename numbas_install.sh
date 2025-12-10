apt install nginx git-core mysql-server \
mysql-common python3 acl libmysqlclient-dev python3-dev \
supervisor python3-pip python3-virtualenv pkg-config

mysql <<EOF
create database numbas_editor;
EOF

mkdir /srv/numbas{,/compiler,/editor,/media,/previews,/static}
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