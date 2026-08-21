FROM python:3.9-slim

# Evita que o Python grave arquivos pyc no disco
ENV PYTHONDONTWRITEBYTECODE=1
# Garante que as saídas do Python não fiquem presas no buffer
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instala dependências do sistema necessárias para psycopg2
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expõe a porta usada pela aplicação
EXPOSE 8081

# Cria e usa um usuário não-root por segurança
RUN useradd -m appuser
USER appuser

# O gunicorn é a melhor escolha para produção, conforme listado no requirements.txt
CMD ["gunicorn", "--bind", "0.0.0.0:8081", "app:app"]
