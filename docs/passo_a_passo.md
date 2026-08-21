# 🚀 Passo a Passo Completo para Execução Local (No Windows)

Este guia expande o README original, fornecendo os comandos exatos de terminal (**focados no Windows e no PowerShell**) para configurar toda a infraestrutura e rodar a aplicação "do zero" na sua máquina.

Para facilitar a configuração dos bancos de dados, utilizaremos o **Docker Desktop para Windows**. Para os recursos da AWS (DynamoDB e SQS), utilizaremos o **AWS CLI**.

---

## 🛠️ Pré-requisitos Fundamentais

Antes de iniciar, garanta que seu ambiente possui as seguintes ferramentas:

1.  **Python 3.9+**: Verifique no PowerShell rodando `python --version`
2.  **Go 1.21+**: Verifique no PowerShell rodando `go version`
3.  **Docker Desktop**: Instalado e rodando. Verifique no PowerShell com `docker --version`
4.  **AWS CLI**: Instalado para Windows.
    *   Verifique rodando: `aws --version`
    *   Para configurar suas credenciais (caso tenha uma conta na AWS), rode: `aws configure` e informe sua Access Key, Secret Key e região (ex: `us-east-1`).
    *   *(Nota: Caso não queira usar a nuvem real ainda, você pode utilizar o **LocalStack** via Docker para simular a AWS localmente).*

---

## 🏗️ Passo 1: Subindo a Infraestrutura de Dados

### 1.1. PostgreSQL (Bancos Relacionais) com Docker

Abra o seu **PowerShell** na raiz do projeto (`hackathon-DCLT-main`) e execute os comandos abaixo um a um:

```powershell
# Sobe um contêiner do PostgreSQL mapeando a porta padrão 5432
docker run --name solidary-postgres -e POSTGRES_PASSWORD=sua_senha_secreta -p 5432:5432 -d postgres:15

# Aguarde alguns segundos para o banco iniciar completamente antes dos próximos comandos.

# Cria o banco de dados ngo_db (Serviço de ONGs)
docker exec -i solidary-postgres psql -U postgres -c "CREATE DATABASE ngo_db;"

# Cria o banco de dados donation_db (Serviço de Doações)
docker exec -i solidary-postgres psql -U postgres -c "CREATE DATABASE donation_db;"
```

Agora, vamos injetar as tabelas lendo os scripts SQL e jogando para dentro do contêiner:

```powershell
# Executa o script de tabelas no banco ngo_db
Get-Content .\ngo-service\db\init.sql | docker exec -i solidary-postgres psql -U postgres -d ngo_db

# Executa o script de tabelas no banco donation_db
Get-Content .\donation-service\db\init.sql | docker exec -i solidary-postgres psql -U postgres -d donation_db
```

### 1.2. AWS SQS (Fila de Mensageria)

O serviço de doações precisa enviar eventos para uma fila. No PowerShell, crie a fila com o seguinte comando:

```powershell
aws sqs create-queue --queue-name solidary-donations --region us-east-1
```
Anote a **QueueUrl** retornada na resposta do comando. Você precisará dela.

### 1.3. AWS DynamoDB (Banco NoSQL)

O serviço de voluntários usa DynamoDB. Crie a tabela via terminal em uma única linha:

```powershell
aws dynamodb create-table --table-name SolidaryTechVolunteers --attribute-definitions AttributeName=volunteer_id,AttributeType=S --key-schema AttributeName=volunteer_id,KeyType=HASH --billing-mode PAY_PER_REQUEST --region us-east-1
```

---

## ⚙️ Passo 2: Configuração das Variáveis de Ambiente (.env)

Agora que as estruturas existem, precisamos conectar o código a elas. Vamos criar os arquivos `.env`.

Ainda no **PowerShell** na raiz do projeto, execute:

```powershell
New-Item -Path .\ngo-service\.env -ItemType File -Force
New-Item -Path .\donation-service\.env -ItemType File -Force
New-Item -Path .\volunteer-service\.env -ItemType File -Force
```

Abra os arquivos gerados (usando o Bloco de Notas ou VS Code) e preencha da seguinte forma:

**Arquivo: `ngo-service\.env`**
```env
PORT=8081
# Conecta no nosso docker (usuário: postgres, senha: sua_senha_secreta)
DATABASE_URL="postgres://postgres:sua_senha_secreta@localhost:5432/ngo_db"
```

**Arquivo: `donation-service\.env`**
```env
PORT=8082
# Conecta no nosso docker (usuário: postgres, senha: sua_senha_secreta)
DATABASE_URL="postgres://postgres:sua_senha_secreta@localhost:5432/donation_db"
AWS_REGION="us-east-1"
# Substitua pela URL que foi gerada no passo 1.2
AWS_SQS_URL="https://sqs.us-east-1.amazonaws.com/SEU_ACCOUNT_ID/solidary-donations"
```

**Arquivo: `volunteer-service\.env`**
```env
PORT=8083
AWS_REGION="us-east-1"
AWS_DYNAMODB_TABLE="SolidaryTechVolunteers"
```

---

## ▶️ Passo 3: Inicializando os Microsserviços

Abra **3 janelas separadas do PowerShell** na raiz do projeto (`hackathon-DCLT-main`).

### 🟡 Terminal 1 — NGO Service (Serviço de ONGs - Python)

O `gunicorn` citado no README original não funciona nativamente no Windows. Usaremos o servidor do Flask para o ambiente local.

```powershell
cd .\ngo-service\

# Cria o ambiente virtual
python -m venv venv

# Ativa o ambiente virtual
.\venv\Scripts\Activate

# Instala as dependências
pip install -r requirements.txt

# Roda a aplicação na porta 8081 usando o Flask (já que o Gunicorn é apenas para Linux)
flask --app app run --host=0.0.0.0 --port=8081
```

### 🟠 Terminal 2 — Donation Service (Serviço de Doações - Go)

```powershell
cd .\donation-service\

# Baixa e sincroniza as dependências do Go
go mod tidy

# Compila e roda o servidor (Subirá na porta 8082)
go run .
```

### 🔵 Terminal 3 — Volunteer Service (Serviço de Voluntários - Python)

```powershell
cd .\volunteer-service\

# Cria o ambiente virtual
python -m venv venv

# Ativa o ambiente virtual
.\venv\Scripts\Activate

# Instala as dependências
pip install -r requirements.txt

# Roda a aplicação na porta 8083 usando o Flask
flask --app app run --host=0.0.0.0 --port=8083
```

---
### 🎉 Conclusão
Agora você tem os três microsserviços rodando localmente no **Windows**, conectados aos bancos PostgreSQL no Docker e serviços da AWS. 
Para validar, você pode acessar pelo navegador ou fazer requisições para:
*   `http://localhost:8081` (NGO Service)
*   `http://localhost:8082` (Donation Service)
*   `http://localhost:8083` (Volunteer Service)
