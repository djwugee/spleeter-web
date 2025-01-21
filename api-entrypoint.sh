#!/bin/bash

set -e

# Collect static files (only in production)
if [[ -z "${DJANGO_DEVELOPMENT}" ]]; then
    echo "Waiting for asset creation"
    while [ ! -d /webapp/frontend/assets/dist ]; do
        sleep 1
    done
    echo "Collect static files"
    python3.9 manage.py collectstatic --noinput
fi

echo "Applying migrations"
python3.9 manage.py makemigrations api
python3.9 manage.py migrate

echo "Starting server"
if [[ -z "${DJANGO_DEVELOPMENT}" ]]; then
    # Use Gunicorn for production
    exec gunicorn -b 0.0.0.0:${PORT:-8000} django_react.wsgi
else
    # Use Django development server for local development
    exec python3.9 manage.py runserver 0.0.0.0:${PORT:-8000}
fi
