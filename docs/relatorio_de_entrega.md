# 🎓 Relatório Técnico de Entrega - Hackathon Fase 5 (Pós-Tech FIAP)

**Projeto:** SolidaryTech (Arquitetura de Microsserviços para Impacto Social)  
**Fase:** Fase 5 - Hackathon Final  
**Ambiente de Nuvem:** Amazon Web Services (AWS) - AWS Academy Learner Lab  
**Data da Execução:** Setembro / 2026  

---

## 📌 1. Resumo Executivo

Este relatório documenta a entrega final da infraestrutura em nuvem, conteinerização e orquestração do ecossistema **SolidaryTech**. Todos os componentes foram provisionados na nuvem da AWS via automação por linha de comando (CLI/Terraform) e estão preparados para esteiras de CI/CD automatizadas (GitHub Actions).

A solução é composta por 3 microsserviços distribuídos (`ngo-service`, `donation-service` e `volunteer-service`), bancos relacionais e NoSQL, mensageria assíncrona, e um cluster Kubernetes elástico gerenciado (**AWS EKS**).

---

## 🛠️ 2. Registro Completo de Modificações, Correções e Decisões de Engenharia

Durante o processo de subida e validação para a nuvem da AWS, foram identificados e solucionados desafios técnicos reais de infraestrutura, compilação de código e orquestração. Abaixo está o registro detalhado de tudo o que foi alterado e ajustado:

### 2.1. Infraestrutura como Código (Terraform) & AWS

1. **Atualização da Versão do Kubernetes no EKS (1.28 ➔ 1.30):**
   - **Cenário Identificado:** A AWS descontinuou o suporte à criação de novos clusters na versão 1.28 (`InvalidParameterException: unsupported Kubernetes version 1.28`).
   - **Ação Tomada:** O arquivo `terraform/main.tf` foi atualizado para utilizar o Kubernetes **v1.30** (`version = "1.30"`).
   - **Impacto:** Conformidade com a política de ciclo de vida da AWS e garantia de suporte a recursos modernos da API do Kubernetes.

2. **Compatibilidade de Nós e AMI (Amazon Linux 2023):**
   - **Cenário Identificado:** Para a versão 1.30 do Kubernetes no EKS, a AMI legada Amazon Linux 2 (AL2) deixou de ser aceita para provisionamento padrão (`InvalidParameterException: Requested AMI for this version 1.30 is not supported`).
   - **Ação Tomada:** O recurso `aws_eks_node_group.spot_nodes` foi configurado explicitamente com `ami_type = "AL2023_x86_64_STANDARD"`.
   - **Impacto:** Nós inicializados com o novo kernel e otimizações do Amazon Linux 2023, atingindo o status `Ready` no cluster.

3. **Resolução de Colisão Global no S3 Backend do Terraform:**
   - **Cenário Identificado:** O bucket genérico `solidarytech-terraform-state-hackathon` já estava registrado por outro usuário no namespace global do S3 (`BucketAlreadyExists`).
   - **Ação Tomada:** Aplicada a convenção recomendada de atrelar o AWS Account ID ao nome do bucket: `solidarytech-terraform-state-857799120036`. O bucket foi criado e parametrizado no backend do `terraform/main.tf`.
   - **Impacto:** Isolamento completo e persistência segura do estado (`terraform.tfstate`) na AWS.

4. **Princípios de FinOps Implementados na Nuvem:**
   - Utilização de nós **Spot** (`capacity_type = "SPOT"`) com instâncias `t3.medium`, reduzindo em até 70% o custo operacional de computação.
   - Tabela DynamoDB provisionada no modo sob demanda (`billing_mode = "PAY_PER_REQUEST"`), eliminando custos com capacidade ociosa.
   - Tags obrigatórias de alocação de custo injetadas globalmente via provider: `Project = "SolidaryTech"`, `Environment = "Production"`, `CostCenter = "NGO-Core"`.

---

### 2.2. Microsserviços e Conteinerização (Docker)

1. **Correção Semântica de Dependências no Go (`donation-service/go.mod`):**
   - **Cenário Identificado:** O arquivo `go.mod` declarava incorretamente o subpacote `github.com/jackc/pgx/v4/stdlib v4.18.3 // indirect` como um módulo separado, violando o parser de módulos do Go (`version "v4.18.3" invalid: should be v0 or v1, not v4`).
   - **Ação Tomada:** Removida a linha espúria e executado `go mod tidy` para sincronizar e gerar o arquivo de integridade `go.sum`.
   - **Impacto:** Resolução completa da árvore de dependências no pipeline de build.

2. **Remoção de Imports Não Utilizados no Go (`donation-service/main.go`):**
   - **Cenário Identificado:** O compilador do Go é rigoroso quanto a dependências não utilizadas e rejeitava a compilação do container com erros em `"fmt"` e `"strconv"`.
   - **Ação Tomada:** Removidos os pacotes não utilizados do bloco `import`.
   - **Impacto:** Compilação estática bem-sucedida (`CGO_ENABLED=0 GOOS=linux go build`).

3. **Otimização do Dockerfile Multistage (`donation-service/Dockerfile`):**
   - **Ação Tomada:** Atualizado o estágio `builder` para copiar tanto `go.mod` quanto `go.sum` (`COPY go.mod go.sum ./`) antes da instrução `RUN go mod download`.
   - **Impacto:** Otimização do cache de camadas do Docker e builds reprodutíveis.

4. **Publicação no Amazon ECR:**
   - Todas as 3 imagens foram construídas e enviadas para os respectivos repositórios privados no Amazon ECR:
     - `857799120036.dkr.ecr.us-east-1.amazonaws.com/solidarytech/ngo-service:latest`
     - `857799120036.dkr.ecr.us-east-1.amazonaws.com/solidarytech/volunteer-service:latest`
     - `857799120036.dkr.ecr.us-east-1.amazonaws.com/solidarytech/donation-service:latest`

---

### 2.3. Orquestração e Kubernetes (`k8s/`)

1. **Roteamento para Imagens no Registro Privado (Amazon ECR):**
   - **Cenário Identificado:** Os arquivos de Deployment em `k8s/` continham referências locais/padrão (`solidarytech/...:latest`), que causariam falhas de `ImagePullBackOff` no cluster EKS da AWS.
   - **Ação Tomada:** Atualizados os campos `image` dos arquivos `k8s/ngo-service.yaml`, `k8s/volunteer-service.yaml` e `k8s/donation-service.yaml` com as URIs absolutas do Amazon ECR.

2. **Parametrização da Fila SQS Real:**
   - **Ação Tomada:** No arquivo `k8s/configmap-secrets.yaml`, substituído o placeholder `AWS_SQS_URL: "https://sqs.us-east-1.amazonaws.com/123/..."` pela URL real da fila criada pelo Terraform:
     `https://sqs.us-east-1.amazonaws.com/857799120036/solidary-donations`.

3. **Rightsizing de Recursos:**
   - Os Deployments contêm definições estritas de `requests` e `limits` de CPU e memória, garantindo densidade adequada nos nós e prevenindo saturação (*OOMKilled*).

4. **Implantação do PostgreSQL no Kubernetes (`k8s/postgres.yaml`):**
   - **Cenário:** As aplicações relacionais (`ngo-service` e `donation-service`) demandavam instâncias ativas do PostgreSQL com os bancos `ngo_db` e `donation_db`.
   - **Ação Tomada:** Criado o manifesto `k8s/postgres.yaml` provisionando um Deployment com PostgreSQL 15, um Service `postgres-host` resolvido pelo CoreDNS e um ConfigMap contendo o script de inicialização (`init.sql`) para criação automática dos bancos e schemas.
   - **Resultado:** Conexão imediata e estabilização de todos os pods com status `1/1 Running` e 0 restarts.

5. **Instalação e Configuração do ArgoCD (GitOps Oficial):**
   - **Cenário:** O edital exige entrega contínua com GitOps ("Não haverá deploy manual via kubectl... mostre o deploy no cluster via ArgoCD").
   - **Ação Tomada:** Instalado o conjunto oficial de controladores, serviços e CRDs do ArgoCD no namespace `argocd` utilizando Server-Side Apply. Criado e aplicado o manifesto `k8s/argocd-application.yaml` para orquestração contínua baseada no repositório Git.
   - **Resultado:** 7 componentes do ArgoCD ativos e operando em status `1/1 Running`.

---

### 2.4. Documentação de Entrega e Opções de Deploy

Atendendo às diretrizes do projeto, foram detalhadas duas estratégias completas de execução nos guias `docs/como_rodar_o_projeto.md` e `docs/passo_a_passo.md`:

1. **Opção 1: 100% via Terminal (CLI):** Roteiro com comandos passo a passo em PowerShell para configuração de credenciais, execução do Terraform, build/push no Docker Desktop e aplicação dos manifestos via `kubectl`.
2. **Opção 2: Automatizada via GitHub Actions:** Roteiro utilizando o script de rotação de segredos (`update-github-secrets.ps1`) e acionamento manual (`workflow_dispatch`) para Terraform Apply e pipelines de CI/CD dos microsserviços.

---

## 📊 3. Evidências de Validação na AWS

### 3.1. Recursos Criados no Terraform
```text
Apply complete! Resources: 26 added, 0 changed, 0 destroyed.

Outputs:
dynamodb_table_name  = "SolidaryTechVolunteers"
eks_cluster_endpoint = "https://5E31636B06BF30E5BBC9464ADB7A435C.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_name     = "solidarytech-cluster"
sqs_queue_url        = "https://sqs.us-east-1.amazonaws.com/857799120036/solidary-donations"
```

### 3.2. Status dos Nós no Cluster EKS (Kubernetes 1.30)
```text
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-1-199.ec2.internal   Ready    <none>   19m   v1.30.14-eks-8f14419
ip-10-0-2-183.ec2.internal   Ready    <none>   19m   v1.30.14-eks-8f14419
```

### 3.3. Todos os Pods das Aplicações (1/1 Running)
```text
NAME                                 READY   STATUS    RESTARTS   AGE
donation-service-5c8c98789b-4l7fj    1/1     Running   0          23s
donation-service-5c8c98789b-nl59t    1/1     Running   0          26s
donation-service-5c8c98789b-vfvkt    1/1     Running   0          22s
ngo-service-56ddb596c-k78sg          1/1     Running   0          28s
ngo-service-56ddb596c-qmckp          1/1     Running   0          29s
postgres-host-746f54d78f-64d2b       1/1     Running   0          5m30s
volunteer-service-7c4cdc6ddd-ssrnq   1/1     Running   0          27s
volunteer-service-7c4cdc6ddd-zfsq2   1/1     Running   0          23s
```

### 3.4. Componentes do ArgoCD (GitOps) no Cluster EKS
```text
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          3m
argocd-applicationset-controller-6d86cc745b-5fsw5   1/1     Running   0          3m
argocd-dex-server-5747b4f5b7-ld2xx                  1/1     Running   0          3m
argocd-notifications-controller-d649c5896-727sf     1/1     Running   0          3m
argocd-redis-f4c9697d-gg7p7                         1/1     Running   0          3m
argocd-repo-server-6cdddb5fd9-9cs8s                 1/1     Running   0          3m
argocd-server-6fdd8cb549-9mm5p                      1/1     Running   0          3m
```

---

## ✅ 4. Conclusão

A arquitetura foi implantada com sucesso na AWS, respeitando as restrições de permissões do perfil acadêmico (`LabRole`), adotando boas práticas de DevSecOps, FinOps e infraestrutura resiliente em Kubernetes. Toda a esteira de código, manifests e documentação está padronizada e pronta para avaliação.
