# 📝 Tudo o que foi feito até agora

Este documento serve como um log de registro das atividades realizadas no repositório até o momento, para manter o grupo alinhado.

## ✅ O que já foi realizado:

1. **Revisão da Documentação e Setup Local:**
   - Lemos e interpretamos o `README.md` e o escopo oficial (PDF) do Hackathon da Fase 5.
   - Criamos o `docs/passo_a_passo.md` (tutorial detalhado focado em Windows/PowerShell e Flask, incluindo setup do PagerDuty).
   - Criamos o `docs/como_rodar_o_projeto.md` (guia com o script de rotacionar credenciais do AWS Academy).

2. **Conteinerização (Docker):**
   - Criados `Dockerfile` para `ngo-service` (Python), `volunteer-service` (Python) e `donation-service` (Go multistage).

3. **Infraestrutura como Código (Terraform) + FinOps:**
   - Configurada a fundação na pasta `terraform/` (backend S3 e ECRs).
   - Substituído o módulo oficial do EKS por **recursos nativos (`aws_eks_cluster`)** para contornar o bloqueio de `iam:GetRole` do AWS Academy, utilizando a `LabRole` obrigatória.
   - Inseridas as **Tags Obrigatórias de FinOps** no provider (`Project`, `Environment`, `CostCenter`).
   - Adicionado RDS PostgreSQL (`aws_db_instance.postgres`).
   - Adicionado DynamoDB (`aws_dynamodb_table`).
   - Adicionado SQS (`aws_sqs_queue`).

4. **Orquestração e Rightsizing (Kubernetes):**
   - Criados os manifestos na pasta `k8s/` e implementado o **Rightsizing** (limites e requests).

5. **DevSecOps e CI/CD (GitHub Actions):**
   - Pipeline refatorada em múltiplos arquivos separados por serviço (`ngo-service-ci.yml`, `donation-service-ci.yml`, `volunteer-service-ci.yml`).
   - Pipelines do Terraform desmembradas (Validate no PR, Apply manual, Destroy manual).
   - Criado o script `update-github-secrets.ps1` usando o `gh CLI` para automação dos segredos da AWS Academy.
   - Criado `.github/workflows/terraform-apply.yml` com aplicação automática.
   - Criado `.github/workflows/terraform-validate.yml` com validação no PR.
   - Criado `.github/workflows/terraform-destroy.yml` com destruição manual protegida.
   - Criado `.github/workflows/update-envs.yml` para atualizar ConfigMap automaticamente.
   - Criado `.github/workflows/k8s-deploy.yml` para deploy automático no K8s.
   - Criado `.github/workflows/ecr-build-push.yml` para build e push automático das imagens Docker.

6. **GitOps (ArgoCD):**
   - Criado o arquivo `k8s/argocd-application.yaml`.

7. **Automação Completa (Fase 5):**
   - Criado `.env` para cada serviço (`ngo-service`, `donation-service`, `volunteer-service`).
   - Criado `.env.example` como template.
   - Criado `.gitignore` para ignorar arquivos `.env`.
   - Criado `docs/passo_a_passo_final.md` com checklist de entrega.
   - Atualizado `terraform/main.tf` com bucket S3 dinâmico (`solidarytech-tf-state-{ACCOUNT_ID}`).
   - Corrigidas versões do RDS (`15`) e EKS (`1.30`).

8. **Deploy na AWS (Dupla Opção: Terminal vs GitHub Actions):**
   - Documentado em `docs/como_rodar_o_projeto.md` e `docs/passo_a_passo.md` o fluxo completo de subida para a AWS cobrindo as duas abordagens: manual via Terminal (PowerShell) e automatizada via GitHub Actions (`workflow_dispatch`).

9. **Ajustes Técnicos e Correções de Engenharia para a Entrega na AWS:**
   - **Upgrade de Versão do EKS (Kubernetes 1.30):** Atualizado `terraform/main.tf` de 1.28 para 1.30 devido à descontinuação de criação da versão 1.28 pela AWS.
   - **Compatibilidade de Nós EKS (AMI AL2023):** Configurado `ami_type = "AL2023_x86_64_STANDARD"` para os nós spot do Kubernetes 1.30.
   - **S3 Backend com Naming Global Único:** Criação e configuração do bucket de state com o Account ID (`solidarytech-terraform-state-857799120036`), contornando colisão global de nomes no S3.
   - **Correção no `donation-service` (Go):**
     - Removida dependência incorreta de subpacote no `go.mod` e gerado o `go.sum` via `go mod tidy`.
     - Removidos imports não utilizados (`fmt` e `strconv`) em `main.go` que barravam a compilação do container.
     - Ajustado o `Dockerfile` multistage para copiar o `go.sum`.
   - **Integração dos Manifestos Kubernetes com a AWS:**
     - Deployments atualizados para puxar imagens do Amazon ECR privado (`857799120036.dkr.ecr.us-east-1.amazonaws.com/...`).
     - Secrets/ConfigMaps atualizados com a URL real da fila SQS provisionada (`solidary-donations`).

10. **Implantação de Banco Relacional Dedicado no Kubernetes (`k8s/postgres.yaml`):**

- Criado e aplicado o manifesto com PostgreSQL 15, service `postgres-host` e ConfigMap de inicialização criando `ngo_db` e `donation_db`.
- Todos os pods dos 3 microsserviços estabilizados e operando com status `1/1 Running` (0 restarts).

11. **GitOps com ArgoCD Ativado no Cluster EKS:**

- Instalados os CRDs, serviços e controladores do ArgoCD no namespace `argocd` via Server-Side Apply.
- Aplicado o manifesto `k8s/argocd-application.yaml` para orquestração declarativa contínua.

---

## 📊 Status Consolidado da Infraestrutura e Deploy na AWS

- **Bucket S3 State:** `solidarytech-terraform-state-857799120036` (Criado e ativo)
- **VPC & Networking:** `solidarytech-vpc` (10.0.0.0/16, Subnets privadas/públicas, IGW, NAT Gateway)
- **Mensageria & NoSQL:** Fila SQS `solidary-donations` e DynamoDB `SolidaryTechVolunteers` (Modo Pay-per-request / FinOps)
- **Repositórios ECR:** Repositórios criados e com imagens versionadas dos 3 microsserviços.
- **Cluster EKS:** `solidarytech-cluster` ativo com 2 nós Spot (`t3.medium`) em status `Ready`.
- **GitOps (ArgoCD):** 7 componentes ativos no namespace `argocd` gerenciando `solidarytech-apps`.
- **Deployments & Services:** Todos os pods das aplicações e do PostgreSQL em status `1/1 Running`.

---

## 🚧 O que está faltando (Próximos Passos pelo Grupo)

- [x] Aplicar o Terraform na AWS Academy. _(Provisionado com sucesso)_
- [x] Executar o deploy no cluster EKS com as credenciais ativas da sessão. _(Realizado: ECR, EKS Cluster 1.30, Worker Nodes e Deployments ativos)_
- [x] Conectar os serviços reais (AWS SQS, DynamoDB e PostgreSQL) no Kubernetes. _(Realizado: Postgres no cluster, SQS e DynamoDB integrados)_
- [x] Ativar o GitOps via ArgoCD no cluster EKS. _(Instalado e Application aplicada)_
- [x] Finalizar as configurações de SRE (Dashboards Grafana `k8s/monitoring/dashboards/` + Alertas `k8s/monitoring/alerts/`).
- [x] Documentar o Plano de Continuidade de Negócios (`docs/pcn/README.md`) e Ciclo ITSM (`docs/itsm/ciclo.md`).
