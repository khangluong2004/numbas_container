echo "vWaRBwTpHoPUhurwmDXDBJRqTSsXtqyEQqPqyxdVCWYrrnyBnI" | docker secret create numbas_editor -
echo "adminpass" | docker secret create numbas_admin_password -
echo "postgrespass" | docker secret create postgres_password -
