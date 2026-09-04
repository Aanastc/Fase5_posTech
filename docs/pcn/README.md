# Plano de Continuidade de Negócios (PCN) - SolidaryTech

## 1. Objetivo

Garantir a disponibilidade, resiliência e pronta recuperação das operações dos microsserviços (`ngo-service`, `donation-service`, `volunteer-service`) e de suas dependências em caso de falhas críticas ou incidentes de infraestrutura.

## 2. Riscos Identificados e Mitigações

- **Interrupção de Instâncias Spot (EKS):** Substituição automática de nós afetados gerenciada pelo EKS Managed Node Groups / Auto Scaling.
- **Falha/Corrupção no banco de dados PostgreSQL (RDS):** Perda temporária de conectividade ou degradação de dados.
- **Acúmulo ou falha no processamento de mensagens no SQS:** Garantido via retenção configurada e Dead Letter Queue (DLQ) para isolamento de mensagens com falha.
- **Comprometimento da tabela DynamoDB:** Mitigado pela resiliência regional nativa e modo PAY_PER_REQUEST.

## 3. Estratégias de Recuperação

1. **Banco de Dados (RDS):** Snapshots diários automatizados com retenção configurada, permitindo restauração Point-in-Time (PITR).
2. **Infraestrutura como Código (IaC):** Repositório Terraform com estado remoto versionado e travado no AWS S3 (`solidarytech-terraform-state-${ACCOUNT_ID}`), permitindo a recriação total da infraestrutura em caso de desastre regional.
3. **Implantabilidade e GitOps (ArgoCD):** Sincronização automática dos manifestos declarativos da pasta `k8s/`, reduzindo o tempo de recomposição das aplicações no cluster EKS.
4. **Armazenamento de Imagens (ECR):** Imagens de contêineres versionadas e mantidas nos repositórios ECR para _redeploy_ imediato.

## 4. Métricas de Recuperação (RTO / RPO)

- **RTO (Recovery Time Objective):** 4 horas (Tempo máximo estimado para subir uma nova infraestrutura via Terraform + ArgoCD).
- **RPO (Recovery Point Objective):** 1 hora (Intervalo máximo tolerado para perda de dados em caso de restauração de backup do banco).
