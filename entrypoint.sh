#!/bin/sh



#// This shell script is a script commonly used in Django projects for setting up and running the
#// application. Here's a breakdown of what each part of the script is doing:
if [ "$DATABASE" = "postgres" ]; then
    echo "Waiting for PostgreSQL..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

# Aplicar migrações
echo "🔄 Aplicando migrações..."
python manage.py migrate --noinput

# Coletar arquivos estáticos
echo "📂 Coletando arquivos estáticos..."
python manage.py collectstatic --no-input --clear

# Criar superusuário se ainda não existir
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "🔑 Criando superusuário Django..."
    python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="$DJANGO_SUPERUSER_USERNAME").exists():
    User.objects.create_superuser("$DJANGO_SUPERUSER_USERNAME", "$DJANGO_SUPERUSER_EMAIL", "$DJANGO_SUPERUSER_PASSWORD")
    print("✅ Superusuário criado!")
else:
    print("⚡ Superusuário já existe, pulando criação.")
EOF
fi

# Executar o comando principal (gunicorn ou qualquer outro passado no CMD)
echo "🚀 Iniciando a aplicação..."
exec "$@"
