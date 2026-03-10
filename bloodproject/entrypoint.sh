#!/bin/bash

# Exit on any error
set -e

# Wait for database to be ready
echo "Waiting for database..."
python manage.py wait_for_db


# Run database migrations
echo "Running database migrations..."
python manage.py migrate sessions zero --fake-initial
python manage.py migrate sessions
python manage.py migrate

python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
import os
pwd = os.environ.get('DJANGO_SUPERUSER_PASSWORD', 'admin123')
try:
    user = User.objects.get(username='admin')
    user.is_staff = True
    user.is_superuser = True
    user.set_password(pwd)
    user.save()
    print('Superuser updated')
except User.DoesNotExist:
    User.objects.create_superuser('admin', 'adamritch172@gmail.com', pwd)
    print('Superuser created')
" || true

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start the application
echo "Starting application..."
exec gunicorn --bind 0.0.0.0:8080 --workers 2 --timeout 120 bloodproject.wsgi:application
