# 📝 Tudo o que foi feito até agora

Este documento serve como um log de registro das atividades realizadas no repositório até o momento, para manter o grupo alinhado.

## ✅ O que já foi realizado:

1. **Revisão da Documentação e Setup Local:**
   - Lemos e interpretamos o `README.md` e o escopo oficial (PDF) do Hackathon da Fase 5.
   - Criamos o `docs/passo_a_passo.md` (tutorial detalhado focado em Windows/PowerShell e Flask).
   - Criamos o `docs/como_rodar_o_projeto.md` (guia para rotacionar credenciais do AWS Academy).

2. **Conteinerização (Docker):**
   - Criados `Dockerfile` para `ngo-service` (Python), `volunteer-service` (Python) e `donation-service` (Go multistage), otimizados e baseados nas melhores práticas de segurança e leveza de imagem.

3. **Infraestrutura como Código (Terraform) + FinOps:**
   - Configurada a fundação na pasta `terraform/` (`main.tf`, `variables.tf`, `outputs.tf`).
   - Provisionamento configurado para AWS EKS (Kubernetes), SQS e DynamoDB.
   - Inseridas as **Tags Obrigatórias de FinOps** no provider (`Project`, `Environment`, `CostCenter`) para todos os recursos criados.

4. **Orquestração e Rightsizing (Kubernetes):**
   - Criados os manifestos na pasta `k8s/` (`ngo-service.yaml`, `donation-service.yaml`, `volunteer-service.yaml` e `configmap-secrets.yaml`).
   - Implementado o **Rightsizing** (limites e requests de CPU e Memória) nos Deployments para atender ao critério de FinOps.

5. **DevSecOps e CI/CD (GitHub Actions):**
   - Criada a esteira de integração contínua em `.github/workflows/ci.yml`.
   - Automação pronta para dar o build das imagens Docker a cada commit na branch `main`.
   - Adicionado o **Trivy** para scan automático de vulnerabilidades do código (travando a pipeline em caso de erros críticos).

6. **GitOps (ArgoCD):**
   - Criado o arquivo `k8s/argocd-application.yaml` que guiará o ArgoCD a monitorar a pasta `k8s/` do GitHub para aplicar atualizações automáticas no cluster AWS sem intervenção manual.

---

## 🚧 O que está faltando (Próximos Passos pelo Grupo)
- [ ] Aplicar o Terraform na AWS Academy.
- [ ] Conectar os serviços reais (AWS SQS e DynamoDB) na infraestrutura.
- [ ] Finalizar as configurações de SRE (SLIs, SLOs e Dashboards do Grafana).
- [ ] Documentar o Plano de Continuidade de Negócios (PCN) e Ciclo ITSM.