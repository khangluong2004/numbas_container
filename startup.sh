echo "Hello world"

echo 'Set up mysql'
mysql <<EOF
create user 'numbas_editor'@'localhost' identified by '$PASSWORD';
grant all privileges on numbas_editor.* to 'numbas_editor'@'localhost';
EOF

echo 'Run "first setup" script'
cd /srv/numbas/editor
python first_setup.py

# Keep container running
tail -f /dev/null