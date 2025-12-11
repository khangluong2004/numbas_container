#!/bin/bash
set -e

echo "Hello world"
echo "Activate the virtualenv"
source /opt/numbas_python/bin/activate

echo 'Set up mysql'
service mysql start

# Wait for MySQL to be ready
until mysqladmin ping &>/dev/null; do
    echo "Waiting for MySQL..."
    sleep 1
done

mysql <<EOF
create user 'numbas_editor'@'localhost' identified by '$EDITOR_PASSWORD';
grant all privileges on numbas_editor.* to 'numbas_editor'@'localhost';
EOF

echo "Setup supervisor, gunicorn and nginx"
mkdir /var/log/numbas_editor
chown www-data:www-data /var/log/numbas_editor
chown -R www-data:www-data /srv/numbas/editor

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
    location /numbas-previews {
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

service nginx restart
service supervisor restart


echo 'Run "first setup" script'
cd /srv/numbas/editor
python3 first_setup.py

# Keep container running
supervisord -n  # This keeps container running AND manages your apps
