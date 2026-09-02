# Passo a Passo Final - Entrega Fase 5

Este documento consolida todas as tarefas pendentes para finalizar a entrega do Hackathon da Fase 5.

---

## Ja Criado Automaticamente

Quando o Terraform roda, cria automaticamente:

- **VPC** com subnets publicas/privadas
- **EKS Cluster** + Node Group (spot)
- **RDS PostgreSQL** (bancos NGOs e Doacoes)
- **DynamoDB** (voluntarios)
- **SQS** (fila de doacoes)
- **ECR** (imagens Docker)

---

## Fluxo Automatico

```
PR na main → terraform-validate.yml valida
Merge na main → terraform-apply.yml aplica infraestrutura
               → k8s-deploy.yml faz deploy no K8s
               → ArgoCD sincroniza automaticamente
```

---

## O que ainda falta

### 1. SRE - SLIs, SLOs e Dashboards

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Criar dashboards JSON para:

- Visao geral de cada servico
- Visao do cluster
- HPA e pods

### 2. PCN e ITSM

Criar `docs/pcn/README.md` e `docs/itsm/ciclo.md`

---

## Checklist Pre-Entrega

- [x] Terraform cria toda infraestrutura automaticamente
- [x] CI/CD automatico (PR valida, merge aplica)
- [ ] Prometheus + Grafana
- [ ] Dashboards funcionando
- [ ] Alertas configurados
- [ ] PCN documentado
- [ ] ITSM documentado

---

## Ordem de execucao

1. **Dia 1**: Executar `terraform apply` via merge na main
2. **Dia 2**: Configurar Prometheus/Grafana
3. **Dia 3**: PCN/ITSM
4. **Dia 4**: Validacao final
