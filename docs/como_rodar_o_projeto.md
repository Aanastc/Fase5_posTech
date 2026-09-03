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

### Atualizando as Credenciais no GitHub Actions (CI/CD)

Além de configurar na sua máquina local, você precisa atualizar as credenciais no GitHub para que o CI/CD (Terraform e Docker) consiga publicar os recursos na AWS da sua conta. Criamos um script para atualizar isso rapidinho direto pelo terminal!

1. Se não tiver, instale o **GitHub CLI** rodando no PowerShell como administrador:
   ```powershell
   winget install --id GitHub.cli
   ```
2. Após instalar, faça login no GitHub pelo terminal:
   ```powershell
   gh auth login
   ```
3. Sempre que as chaves da AWS Academy expirarem, rode o script abaixo na pasta do projeto com os seus novos tokens copiados:
   ```powershell
   .\update-github-secrets.ps1 -AccessKey 'COLE_AQUI_A_ACCESS_KEY' -SecretKey 'COLE_AQUI_A_SECRET_KEY' -SessionToken 'COLE_AQUI_O_TOKEN'
   ```

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

---

## 🚀 5. Subindo Tudo para a AWS (Deploy na Nuvem)

Você pode realizar o deploy completo da infraestrutura e dos microsserviços de duas maneiras: **100% via Terminal** ou **Automatizado via GitHub Actions (Run Workflow)**.

---

### Opção A: 100% via Terminal (Execução Manual no PowerShell)

Esta opção dá controle total e imediato de cada etapa diretamente no terminal da sua máquina.

#### 5.1. Configurar as credenciais ativas da AWS no terminal
Certifique-se de que as credenciais do AWS Academy estão ativas no seu terminal antes de executar os comandos:
```powershell
$env:AWS_ACCESS_KEY_ID="COLE_AQUI_O_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="COLE_AQUI_A_SECRET_KEY"
$env:AWS_SESSION_TOKEN="COLE_AQUI_O_TOKEN"
$env:AWS_REGION="us-east-1"
```

Valide se as credenciais estão ativas:
```powershell
aws sts get-caller-identity
```

#### 5.2. Criar o Bucket S3 para o Backend do Terraform (Caso ainda não exista)
O Terraform utiliza o bucket S3 configurado em `terraform/main.tf` para armazenar o estado:
```powershell
aws s3 mb s3://solidarytech-terraform-state-857799120036 --region us-east-1
```

#### 5.3. Provisionar a Infraestrutura com Terraform
Navegue até a pasta `terraform` e execute:
```powershell
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
cd ..
```
> Isso criará: VPC, Subnets, EKS Cluster (`solidarytech-cluster`), Node Group Spot, fila SQS (`solidary-donations`), tabela DynamoDB (`SolidaryTechVolunteers`) e os 3 repositórios no AWS ECR.

#### 5.4. Build e Push das Imagens Docker para o Amazon ECR
Obtenha o seu `Account ID` da AWS e autentique o Docker no ECR:
```powershell
$ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$ECR_REGISTRY = "$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"

# Login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build e Push - NGO Service
docker build -t "$ECR_REGISTRY/solidarytech/ngo-service:latest" ./ngo-service
docker push "$ECR_REGISTRY/solidarytech/ngo-service:latest"

# Build e Push - Donation Service
docker build -t "$ECR_REGISTRY/solidarytech/donation-service:latest" ./donation-service
docker push "$ECR_REGISTRY/solidarytech/donation-service:latest"

# Build e Push - Volunteer Service
docker build -t "$ECR_REGISTRY/solidarytech/volunteer-service:latest" ./volunteer-service
docker push "$ECR_REGISTRY/solidarytech/volunteer-service:latest"
```

#### 5.5. Conectar ao EKS e Aplicar os Manifestos do Kubernetes
Atualize o `kubeconfig` local para apontar para o cluster da AWS e aplique os manifestos da pasta `k8s`:
```powershell
# Atualiza kubeconfig
aws eks update-kubeconfig --region us-east-1 --name solidarytech-cluster

# Aplica ConfigMaps, Secrets e Deployments
kubectl apply -f ./k8s/

# Verifica os pods e serviços em execução
kubectl get pods -o wide
kubectl get svc
```

---

### Opção B: Via GitHub Actions (CI/CD com Run Workflow)

Esta opção utiliza as pipelines automatizadas do repositório no GitHub.

#### 5.1. Atualizar as credenciais nos Secrets do GitHub
Atualize os segredos do repositório utilizando o script `update-github-secrets.ps1` (ou manualmente na aba *Settings -> Secrets and variables -> Actions* do repositório):
```powershell
.\update-github-secrets.ps1 -AccessKey "SUA_ACCESS_KEY" -SecretKey "SUA_SECRET_KEY" -SessionToken "SEU_TOKEN"
```

#### 5.2. Disparar a criação da infraestrutura (Terraform Apply)
1. No GitHub, acesse a aba **Actions**.
2. No menu lateral esquerdo, clique no workflow **Terraform Apply Manual**.
3. Clique no botão **Run workflow**, selecione a branch `main` e confirme.
4. Aguarde a conclusão do job para que a VPC, o EKS e os repositórios ECR sejam provisionados.

#### 5.3. Disparar o Build, Análise de Vulnerabilidade e Deploy dos Serviços
Com os repositórios ECR criados pelo Terraform:
- Faça um `git push` para a branch `main` com alterações dos serviços, **OU**
- Acesse as pipelines de CI de cada serviço na aba **Actions** e dispare o workflow.
- O GitHub Actions irá rodar o build do Docker, escanear com **Trivy** e publicar a imagem diretamente no ECR.

