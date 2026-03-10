FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        build-essential \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY bloodproject/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY bloodproject/ .

RUN chmod +x entrypoint.sh || true

RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /app

EXPOSE 8000

CMD gunicorn bloodproject.wsgi:application --bind 0.0.0.0:${PORT:-8000}
