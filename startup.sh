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
create user 'numbas_editor'@'localhost' identified by '$PASSWORD';
grant all privileges on numbas_editor.* to 'numbas_editor'@'localhost';
EOF

echo 'Run "first setup" script'
cd /srv/numbas/editor
python3 first_setup.py

echo "Setup supervisor, gunicorn and nginx"
mkdir /var/log/numbas_editor
chown www-data:www-data /var/log/numbas_editor


# Keep container running
tail -f /dev/null