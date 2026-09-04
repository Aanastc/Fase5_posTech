# Ciclo ITSM - SolidaryTech

## Fases do Ciclo de Vida do Serviço

1. **Estratégia de Serviço (Service Strategy)**
   - Definição do catálogo de serviços e domínio dos microsserviços (`ngo-service`, `donation-service`, `volunteer-service`).
   - Mapeamento das necessidades de negócio de ONGs, doadores e voluntários.

2. **Design de Serviço (Service Design)**
   - Arquitetura de infraestrutura resiliente na AWS utilizando EKS v1.31, RDS PostgreSQL, SQS e DynamoDB.
   - Modelagem de alta disponibilidade, isolamento por namespaces (`solidarytech`, `monitoring`, `argocd`) e políticas de segurança (Security Groups e Subnets Privadas).

3. **Transição de Serviço (Service Transition)**
   - Provisionamento automatizado de infraestrutura como código (IaC) com Terraform.
   - Pipelines de CI/CD no GitHub Actions para testes, build e push de imagens para o Amazon ECR.
   - Implantação e gerenciamento de mudanças declarativas com ArgoCD (GitOps).

4. **Operação de Serviço (Service Operation)**
   - Monitoramento de saúde e performance com **Prometheus** e **Grafana** (metrics & dashboards).
   - Gestão de incidentes com alertas configurados via **PrometheusRule** (`PodFailing`, `HighMemoryUsage`).
   - Execução de workloads otimizados em nós `SPOT` com autorrecuperação automática.

5. **Melhoria Contínua de Serviço (Continual Service Improvement - CSI)**
   - Acompanhamento de indicadores de desempenho (**SLIs/SLOs**) e acordos de nível de serviço (**SLAs**).
   - Otimização de custos (FinOps) através do uso de instâncias Spot e billing `PAY_PER_REQUEST` no DynamoDB.
   - Análise de relatórios de métricas e ciclo de feedback pós-incidentes.

---

## Matriz de Ferramentas & Capacidades

| Categoria                | Ferramenta           | Papel na Operação ITSM                                |
| :----------------------- | :------------------- | :---------------------------------------------------- |
| **IaC (Infraestrutura)** | Terraform            | Automação e padronização da infraestrutura AWS        |
| **CI/CD**                | GitHub Actions       | Integração contínua e automação de deploys            |
| **GitOps**               | ArgoCD               | Controle de versão de estado e sincronização contínua |
| **Observabilidade**      | Prometheus & Grafana | Coleta de métricas, alarmes e dashboards visuais      |
| **Registry**             | AWS ECR              | Repositório central e seguro de imagens Docker        |
