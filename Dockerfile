FROM python:3.13

WORKDIR /usr/src/app

# Definir variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends gcc netcat-openbsd

# Atualizar pip
RUN pip install --upgrade pip

# Copiar o arquivo de dependências e instalar
COPY ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Criar diretórios e usuário para a app
RUN mkdir -p /home/app/web/staticfiles /home/app/web/mediafiles && \
    addgroup --system app && adduser --system --group app

WORKDIR /home/app/web

# Copiar o código do projeto
COPY . /home/app/web/

# Ajustar permissões
RUN chown -R app:app /home/app/web

# Copiar o entrypoint e torná-lo executável
COPY ./entrypoint.sh /home/app/web/
RUN chmod +x /home/app/web/entrypoint.sh

# Mudar para o usuário app
USER app

# Entrar no entrypoint
ENTRYPOINT ["/home/app/web/entrypoint.sh"]
