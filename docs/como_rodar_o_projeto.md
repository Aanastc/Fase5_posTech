# 🚀 Como Rodar o Projeto (Guia para o Grupo)

Este guia contém as orientações de como o grupo deve iniciar o projeto no dia a dia, especialmente considerando o uso do **AWS Academy** e as credenciais de cada membro.

---

## ☁️ 1. Configurando as Credenciais do AWS Academy

Como estamos utilizando o **AWS Academy**, as credenciais (Access Key, Secret Key e Session Token) **expiram rapidamente** (geralmente a cada 4 horas). Cada membro do grupo precisará atualizar essas credenciais sempre que for trabalhar.

### Onde colar as credenciais?

Quando você iniciar o laboratório no AWS Academy e clicar em "AWS Details", copie as variáveis de ambiente e configure no seu terminal (PowerShell) ANTES de subir a aplicação:

```powershell
$env:AWS_ACCESS_KEY_ID="COLE_AQUI_O_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="COLE_AQUI_A_SECRET_KEY"
$env:AWS_SESSION_TOKEN="COLE_AQUI_O_TOKEN"
$env:AWS_REGION="us-east-1"
```

*(Dica: Outra forma é colar essas informações no arquivo `C:\Users\SEU_USUARIO\.aws\credentials`, mas lembre-se de que cada membro fará isso na própria máquina com a própria conta do Academy).*

---

## 🗄️ 2. Subindo a Infraestrutura Local (Bancos de Dados)

Antes de rodar as aplicações, você precisa ter o Docker Desktop aberto e rodando.

**No PowerShell, execute (apenas na primeira vez que for criar):**
```powershell
docker run --name solidary-postgres -e POSTGRES_PASSWORD=sua_senha_secreta -p 5432:5432 -d postgres:15

# Criando as tabelas e bancos:
docker exec -i solidary-postgres psql -U postgres -c "CREATE DATABASE ngo_db;"
docker exec -i solidary-postgres psql -U postgres -c "CREATE DATABASE donation_db;"

Get-Content .\ngo-service\db\init.sql | docker exec -i solidary-postgres psql -U postgres -d ngo_db
Get-Content .\donation-service\db\init.sql | docker exec -i solidary-postgres psql -U postgres -d donation_db
```

*(Se o seu computador for reiniciado e o banco parar, basta rodar `docker start solidary-postgres` para iniciá-lo novamente, sem precisar recriar as tabelas).*

---

## ⚙️ 3. Variáveis de Ambiente (.env)

Cada membro do grupo precisará ter os arquivos `.env` na raiz de cada microsserviço. **Estes arquivos não sobem para o GitHub** (eles devem estar no `.gitignore`), então cada um deve criá-los na própria máquina.

**ngo-service/.env**:
```env
PORT=8081
DATABASE_URL="postgres://postgres:sua_senha_secreta@localhost:5432/ngo_db"
```

**donation-service/.env**:
```env
PORT=8082
DATABASE_URL="postgres://postgres:sua_senha_secreta@localhost:5432/donation_db"
AWS_REGION="us-east-1"
AWS_SQS_URL="URL_DA_FILA_CRIADA_NO_AWS_ACADEMY"
```

**volunteer-service/.env**:
```env
PORT=8083
AWS_REGION="us-east-1"
AWS_DYNAMODB_TABLE="SolidaryTechVolunteers"
```

---

## ▶️ 4. Rodando as Aplicações

Abra 3 terminais PowerShell (um para cada serviço).

**Terminal 1 (NGO Service)**:
```powershell
cd ngo-service
.\venv\Scripts\Activate
pip install -r requirements.txt
flask --app app run --host=0.0.0.0 --port=8081
```

**Terminal 2 (Donation Service)**:
```powershell
cd donation-service
go mod tidy
go run .
```

**Terminal 3 (Volunteer Service)**:
```powershell
cd volunteer-service
.\venv\Scripts\Activate
pip install -r requirements.txt
flask --app app run --host=0.0.0.0 --port=8083
```
