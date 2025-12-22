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
create user if not exists 'numbas_editor'@'localhost' identified by '$EDITOR_PASSWORD';
grant all privileges on numbas_editor.* to 'numbas_editor'@'localhost';
EOF

# Add www-data to the mysql group
usermod -a -G mysql www-data

# Make sure the socket file has correct permissions
chmod 777 /var/run/mysqld/
chmod 777 /var/run/mysqld/mysqld.sock

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


echo "Updating X-Frame-Options header"
echo "Allow X-frame from anywhere to avoid cross-origin issues when test locally"
echo "NOTE: For testing only, not for production"
if ! grep -q "X_FRAME_OPTIONS = 'ALLOWALL'" /srv/numbas/editor/numbas/settings.py; then
    echo "X_FRAME_OPTIONS = 'ALLOWALL'" >> /srv/numbas/editor/numbas/settings.py
else
    echo "X_FRAME_OPTIONS already configured, skipping"
fi

# Setup the web server
/usr/local/app/web_setup.sh

# Run supervisor on foreground to keep container open
supervisord -n
