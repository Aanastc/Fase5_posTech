# 🔄 Fluxo de Gestão de Incidentes (ITSM) e AIOps - SolidaryTech

Este documento define o ciclo de vida completo de tratamento de incidentes na plataforma SolidaryTech, integrando práticas de ITIL v4 e princípios de AIOps/Observabilidade.

## 1. Ciclo de Vida do Incidente

### Fase 1: Detecção (Identification)

- **Mecanismo:** A métrica é coletada pelo Prometheus no EKS e avaliada em relação às regras de alerta em `k8s/monitoring/alerts/prometheus-rules.yaml`.
- **Gatilho de Alerta:** Se o pod do `donation-service` entrar em estado `Failed` ou `Pending` por mais de 5 minutos, o alerta `PodFailing` é disparado com gravidade `critical`.

### Fase 2: Registros e Acionamento (Logging & Categorization)

- O Alertmanager recebe a notificação do Prometheus, agrupa os alertas por namespace e dispara uma notificação via webhook para o canal de incidentes da equipe.
- É criado automaticamente um ticket de incidente no sistema de chamados categorizado por impacto (ex: P1 - Serviço Crítico Indisponível).

### Fase 3: Investigação e Diagnóstico (Investigation & Diagnosis)

- O engenheiro de plantão utiliza a ponte de comando `kubectl port-forward` para abrir a interface do **Grafana** (`SolidaryTech - Visão Geral`).
- A equipe isola o problema analisando os painéis de **Pods com Erro** e o gráfico temporal de **Uso de Memória por Pod** para identificar eventuais estouros de memória (_OOMKilled_).

### Fase 4: Mitigação e Resolução (Resolution & Recovery)

- **Ação Automatizada (Auto-Healing):** O Kubernetes reinicia pods em falha através do Kubelet. Paralelamente, o Argo CD (`selfHeal: true`) restaura automaticamente qualquer alteração indevida na infraestrutura para o estado do Git.
- **Ação Manual via GitOps:** Se a falha for decorrente de um _deploy_ recente de código com bug, a equipe realiza o _rollback_ imediato da versão utilizando a interface do **Argo CD**, restaurando o serviço em minutos.

### Fase 5: Encerramento e Post-Mortem (Closure & Post-Mortem)

- O incidente é fechado após a normalização dos SLIs no Grafana.
- Em até 48 horas, realiza-se uma reunião de Post-Mortem sem culpabilização (_Blameless Post-Mortem_) para documentar a causa raiz (RCA) e registrar ações preventivas no repositório.

## 2. Abordagem e Estratégia de AIOps

Diante da arquitetura cloud-native utilizada no projeto:

- **Detecção Preditiva de Anomalias (PromQL):** Emprego de funções preditivas nativas do Prometheus (como `predict_linear(container_memory_working_set_bytes[1h], 86400)`) para identificar tendências de vazamento de memória (_memory leak_) antes que o pod sofra _crash_.
- **Centralização e Correlação de Logs:** Estruturação das aplicações para emissão de logs em formato JSON padronizado com correlação de `trace_id`, acelerando a identificação de anomalias no ecossistema de microsserviços.
