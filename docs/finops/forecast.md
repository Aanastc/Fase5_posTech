# 💰 Relatório FinOps: Forecast de Custos e Recomendações - SolidaryTech

Este documento apresenta a projeção de custos mensais na Amazon Web Services (AWS) para o projeto SolidaryTech, aplicando boas práticas de gestão financeira em nuvem (FinOps).

## 1. Projeção Mensal de Custos (Forecast AWS)

A arquitetura foi dimensionada para operar em ambiente de produção mantendo a máxima eficiência de custos utilizando a região `us-east-1`.

| Recurso AWS                | Tipo / Configuração                                  | Custo Estimado Mensal (USD) |
| -------------------------- | ---------------------------------------------------- | --------------------------- |
| **AWS EKS Control Plane**  | Cluster Kubernetes Gerenciado                        | $73.00                      |
| **EC2 Auto Scaling Group** | 2x `t3.medium` (Instâncias Spot)                     | $15.00                      |
| **Amazon RDS PostgreSQL**  | `db.t3.micro` (Single-AZ)                            | $15.00                      |
| **Amazon SQS + DynamoDB**  | Filas e Tabela NoSQL (Camada Free / Pay-per-Request) | $2.00                       |
| **Amazon ECR + S3**        | Armazenamento de Imagens Docker e Terraform State    | $3.00                       |
| **Custo Total Estimado**   | --                                                   | **~$108.00 / mês**          |

## 2. Estratégias de Otimização de Custos Aplicadas

1. **Tagging Obrigatório e Governança de Custos (Cost Allocation Tags):**
   Todos os recursos provisionados via Terraform em `terraform/main.tf` utilizam `default_tags` declarativas (`Project = "SolidaryTech"`, `Environment = "Production"`, `CostCenter = "FinOps"`), permitindo o faturamento detalhado por centro de custo no AWS Cost Explorer.

2. **Utilização de Instâncias Spot no EKS:**
   O Node Group do cluster foi configurado para utilizar instâncias EC2 Spot para o plano de dados dos trabalhadores, gerando uma economia de até **70%** em comparação com o preço _On-Demand_.

3. **Rightsizing de Pods (Requests e Limits):**
   Todos os Deployments Kubernetes em `k8s/` possuem limites rigorosos de CPU e memória (`requests: 128Mi`, `limits: 512Mi`), impedindo o desperdício de recursos nos nós e viabilizando maior densidade de pods por máquina.

4. **Políticas de Lifecycle no Amazon ECR:**
   Configuração de regra de limpeza automática no repositório de contêineres para reter apenas as **5 imagens mais recentes**, evitando acúmulo de custos de armazenamento de imagens legadas.

## 3. Recomendações Práticas para Otimização Futura

- **Uso do Karpenter:** Substituir o Cluster Autoscaler pelo Karpenter para realizar o provisionamento dinâmico e consolidação de nós Spot de forma mais ágil e barata.
- **Desligamento Automático em Horário Não Comercial:** Implementar a ferramenta _Kube-downscaler_ para reduzir as réplicas dos pods para zero fora do horário comercial em ambientes de staging/desenvolvimento.
