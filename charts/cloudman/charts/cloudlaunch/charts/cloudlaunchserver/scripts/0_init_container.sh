#!/bin/sh

echo "Apply database migrations from `pwd`"
/app/venv/bin/python manage.py migrate
# Save last error
errcode=$?
if [ $errcode -eq 0 ]; then
    echo "Migrations successfully applied"
else
    echo "Failed to apply migrations. Quitting..."
    exit $errcode
fi

echo "Load initial data from /app/initial_data/*.json"
/app/venv/bin/python manage.py loaddata /app/initial_data/*.json

echo "Create a superuser"
cat /app/scripts/create_superuser.py | /app/venv/bin/python manage.py shell
errcode=$?
if [ $errcode -eq 0 ]; then
    echo "Successfully created the superuser"
else
    echo "Error creating superuser. Quitting..."
    exit $errcode
fi
