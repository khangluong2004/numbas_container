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

# Add www-data to the mysql group
usermod -a -G mysql www-data

# Make sure the socket file has correct permissions
chmod 777 /var/run/mysqld/
chmod 777 /var/run/mysqld/mysqld.sock

echo 'Run "first setup" script'
cd /srv/numbas/editor
# Run python in background
python3 first_setup.py &
FIRST_SETUP_PID=$!

echo 'Running first setup in background with PID' $FIRST_SETUP_PID
# Wait for the first setup script to finish
wait $FIRST_SETUP_PID || echo "First setup is done"

# Replace the ALLOWED_HOST in settings.py to allow all hosts
echo 'Setting ALLOWED_HOSTS to allow all hosts to access the editor'
sed -i "s/ALLOWED_HOSTS = \[.*\]/ALLOWED_HOSTS = \['\*'\]/" /srv/numbas/editor/numbas/settings.py

# Setup the web server
/usr/local/app/web_setup.sh

# Run supervisor on foreground to keep container open
supervisord -n
