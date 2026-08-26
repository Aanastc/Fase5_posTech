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

4. **Orquestração e Rightsizing (Kubernetes):**
   - Criados os manifestos na pasta `k8s/` e implementado o **Rightsizing** (limites e requests).

5. **DevSecOps e CI/CD (GitHub Actions):**
   - Pipeline refatorada em múltiplos arquivos separados por serviço (`ngo-service-ci.yml`, `donation-service-ci.yml`, `volunteer-service-ci.yml`).
   - Pipelines do Terraform desmembradas (Validate no PR, Apply manual, Destroy manual).
   - Criado o script `update-github-secrets.ps1` usando o `gh CLI` para automação dos segredos da AWS Academy.

6. **GitOps (ArgoCD):**
   - Criado o arquivo `k8s/argocd-application.yaml`.

---

## 🚧 O que está faltando (Próximos Passos pelo Grupo)
- [x] Aplicar o Terraform na AWS Academy. *(Validação aprovada)*
- [ ] Conectar os serviços reais (AWS SQS e DynamoDB) na infraestrutura do Kubernetes.
- [ ] Finalizar as configurações de SRE (SLIs, SLOs e Dashboards do Grafana).
- [ ] Documentar o Plano de Continuidade de Negócios (PCN) e Ciclo ITSM.