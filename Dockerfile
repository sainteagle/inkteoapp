FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH="/opt/venv/bin:$PATH"
ENV DJANGO_SETTINGS_MODULE=core.settings

WORKDIR /app

RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pip install gunicorn

RUN mkdir -p /etc/easypanel/projects/inkteo/inkteo/code/staticfiles \
    /etc/easypanel/projects/inkteo/inkteo/code/static \
    && chmod -R 755 /etc/easypanel/projects/inkteo/inkteo/code/staticfiles \
    /etc/easypanel/projects/inkteo/inkteo/code/static

COPY . .

RUN python manage.py collectstatic --noinput --clear

EXPOSE 80

CMD ["sh", "-c", "python manage.py migrate && gunicorn core.wsgi:application --bind 0.0.0.0:80 --workers 3"]