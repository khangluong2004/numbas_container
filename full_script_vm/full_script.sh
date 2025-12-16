#!/bin/bash
set -e
EDITOR_PASSWORD="password"
apt update

echo "Installing required packages"
apt install nginx git-core mysql-server \
mysql-common python3 acl libmysqlclient-dev python3-dev \
supervisor python3-pip python3-virtualenv pkg-config

echo "Creating numbas user and group, and python virtualenv"
groupadd numbas
usermod khang -a -G numbas,www-data
mkdir -p /opt/numbas_python
setfacl -dR -m g:numbas:rwx /opt/numbas_python
virtualenv -p python3 /opt/numbas_python

source /opt/numbas_python/bin/activate

echo "Setting up MySQL database"
mysql <<EOF
create database if not exists numbas_editor;
create user if not exists 'numbas_editor'@'localhost' identified by '$EDITOR_PASSWORD';
grant all privileges on numbas_editor.* to 'numbas_editor'@'localhost';
EOF

# Add www-data to the mysql group
usermod -a -G mysql www-data

# Make sure the socket file has correct permissions
chmod 777 -R /var/run/mysqld/
chmod 777 -R /var/run/mysqld/mysqld.sock

echo "Create directories and set permissions"
mkdir -p /srv/numbas /srv/numbas/compiler /srv/numbas/editor /srv/numbas/media /srv/numbas/previews /srv/numbas/static
cd /srv/numbas
chmod 2770 media previews
chmod 2750 compiler static
chgrp www-data compiler media previews static
setfacl -dR -m g::rwX media previews
setfacl -dR -m g::rX compiler static

echo "Clone the editor and compiler repositories"
git clone https://github.com/numbas/Numbas /srv/numbas/compiler
git clone https://github.com/numbas/editor /srv/numbas/editor

echo "Installing Python dependencies"
pip install -r /srv/numbas/editor/requirements.txt
pip install -r /srv/numbas/compiler/requirements.txt
pip install mysqlclient gunicorn

if [ ! -f /srv/numbas/editor/numbas/settings.py ]; then
    echo 'Run "first setup" script'
    cd /srv/numbas/editor
    # Run python in background
    python3 first_setup.py &
    FIRST_SETUP_PID=$!

    echo 'Running first setup in background with PID' $FIRST_SETUP_PID
    # Wait for the first setup script to finish
    wait $FIRST_SETUP_PID || echo "First setup is done"
else
    echo 'Skipping first setup - settings.py already exists'
fi

mkdir -p /var/log/numbas_editor
chown www-data:www-data /var/log/numbas_editor
chown -R www-data:www-data /srv/numbas

echo "Updating X-Frame-Options header"
echo "Allow X-frame from anywhere to avoid cross-origin issues when test locally"
echo "NOTE: For testing only, not for production"
if ! grep -q "X_FRAME_OPTIONS = 'ALLOWALL'" /srv/numbas/editor/numbas/settings.py; then
    echo "X_FRAME_OPTIONS = 'ALLOWALL'" >> /srv/numbas/editor/numbas/settings.py
else
    echo "X_FRAME_OPTIONS already configured, skipping"
fi

echo "Setup supervisor, gunicorn and nginx"
cat > /srv/numbas/editor/web/gunicorn.conf.py <<EOF
# Serve on port 8001
bind = "0.0.0.0:8001"
# Number of worker processes to run. Increase when there is more traffic.
workers = 1
# Access log - records incoming HTTP requests
accesslog = "/var/log/numbas_editor/numbas_editor_access.log"
# Error log - records Gunicorn server goings-on
errorlog = "/var/log/numbas_editor/numbas_editor_error.log"
# Whether to send Django output to the error log
capture_output = True
# How verbose the Gunicorn error logs should be
loglevel = "info"
EOF

cat > /etc/supervisor/conf.d/numbas_editor.conf <<EOF
[program:numbas_editor]
command=/opt/numbas_python/bin/gunicorn -c /srv/numbas/editor/web/gunicorn.conf.py web.wsgi:application
directory=/srv/numbas/editor/
user=www-data
autostart=true
autorestart=true
stopasgroup=true
environment=DJANGO_SETTINGS_MODULE=numbas.settings
numprocs=1

[program:numbas_editor_huey]
command=/opt/numbas_python/bin/python /srv/numbas/editor/manage.py run_huey
directory=/srv/numbas/editor/
user=www-data
autostart=true
autorestart=true
stopasgroup=true
environment=DJANGO_SETTINGS_MODULE=numbas.settings
numprocs=1
EOF

cat > /etc/nginx/sites-enabled/default <<EOF
server {
    listen 80;

    client_max_body_size 100M;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        alias /srv/numbas/static/;
    }
    location /media/ {
        alias /srv/numbas/media/;
    }
    location /numbas-previews/ {
        alias /srv/numbas/previews/;
        add_header 'Access-Control-Allow-Origin' '*';
    }

    location / {
        include proxy_params;
        proxy_pass http://localhost:8001;
        proxy_read_timeout 120s;
    }
}
EOF

echo "Restarting nginx and supervisor"
systemctl restart nginx supervisor
