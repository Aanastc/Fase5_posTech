# 📈 Definição de SLIs, SLOs e Error Budget - SolidaryTech

Este documento estabelece os Indicadores de Nível de Serviço (SLIs) e Objetivos de Nível de Serviço (SLOs) para o microserviço crítico `donation-service`, garantindo a confiabilidade da plataforma de doações.

## 1. Indicadores de Nível de Serviço (SLIs)

- **SLI 1 (Disponibilidade / Taxa de Erro):** Proporção de requisições HTTP recebidas com sucesso (status diferente de 5xx) em relação ao total de requisições.
  - _Fórmula:_ `(Requisições HTTP Sucesso / Total Requisições HTTP) * 100`
- **SLI 2 (Latência):** Proporção de requisições HTTP do tipo `POST /donations` processadas e respondidas em menos de 200 milissegundos.
  - _Fórmula:_ `(Requisições < 200ms / Total Requisições) * 100`

## 2. Objetivos de Nível de Serviço (SLOs)

| Serviço            | Métrica         | Meta (SLO)                                         | Janela de Avaliação |
| ------------------ | --------------- | -------------------------------------------------- | ------------------- |
| `donation-service` | Disponibilidade | **99.5%** de requisições com status 2xx/4xx        | 30 dias móveis      |
| `donation-service` | Latência        | **95.0%** das requisições respondidas em `< 200ms` | 30 dias móveis      |

## 3. Orçamento de Erro (Error Budget)

Com base no SLO de 99.5% de disponibilidade em um período de 30 dias (720 horas):

- **Tolerância de Indisponibilidade:** 0.5% do tempo total.
- **Tempo Limite de Indisponibilidade Permitido:** **3.6 horas/mês** (216 minutos).
- **Política de Esgotamento do Error Budget:**
  - Se o Error Budget atingir **0%**, congelam-se novas implementações de funcionalidades (_feature freeze_).
  - Toda a equipe de desenvolvimento passa a focar exclusivamente em correções de bugs, testes de carga e melhorias de infraestrutura e estabilidade.

## 4. Estratégia de Redução de MTTR (Mean Time to Recover)

- **Detecção Automática:** Utilização do `PrometheusRule` (`PodFailing` e `HighMemoryUsage`) integrado ao Alertmanager para detecção em menos de 1 minuto.
- **Mitigação Rápida:** O Argo CD com a flag `selfHeal: true` permite o _rollback_ e a reconciliação declarativa instantânea para o estado do Git caso ocorra desvio ou falha.
- **Auto-Healing de Contêineres:** O Kubernetes gerencia a saúde das réplicas e reinicia automaticamente pods em falha através das políticas de restart do Kubelet.
- **Meta de MTTR:** Redução do tempo médio de recuperação de **45 minutos** para menos de **5 minutos**.
