# 🎬 Roteiro de Gravação - Entregáveis da Fase 5 (Duas Pessoas)

Este roteiro atende **exatamente** aos requisitos da banca (Pitch Executivo + Demo Tech). A apresentação é dividida para **duas pessoas** (Pessoa 1 e Pessoa 2).

---

## 🟢 CENA 1: O Pitch Executivo (Vendendo para a Diretoria)
**🎙️ Pessoa 1** assume a palavra.
- **Objetivo:** Vender a arquitetura, PCN e viabilidade financeira (FinOps) para a diretoria.

**FALA (Pessoa 1):** 
> "Olá, prezada diretoria da SolidaryTech. Hoje apresentamos a evolução arquitetural da nossa plataforma de doações. O grande foco dessa nova versão foi trazer viabilidade financeira, segurança de ponta a ponta e altíssima disponibilidade. 
> 
> No lado financeiro (FinOps), garantimos previsibilidade: aplicamos *Rightsizing* nos nossos nós e contêineres, além de adotar Instâncias Spot, o que nos permitiu projetar um custo mensal na casa de 100 dólares. Tudo está rigorosamente tagueado via código, então cada centavo gasto é rastreado para o seu devido centro de custo.
> 
> No lado da Segurança e Continuidade de Negócios (PCN), nós não brincamos em serviço. Desenhamos um processo formal de ITSM para gestão de incidentes. E se um desastre acontecer na AWS? Temos uma estratégia de **Disaster Recovery** em Multi-AZ. Toda nossa infraestrutura está espalhada em mais de um data center físico, e nosso banco de dados tem backups automatizados, garantindo um RPO de apenas 15 minutos e RTO de 1 hora. A plataforma está pronta para escalar com responsabilidade."

---

## 🟢 CENA 2: Demo Tech - CI/CD e ArgoCD
**🎙️ Pessoa 2** assume a palavra.
- **Objetivo:** Mostrar os pipelines rodando e o deploy no cluster.

**💻 Ação no Navegador:**
*(Abra o GitHub do projeto na aba 'Actions')*

**FALA (Pessoa 2):**
> "Entrando na Demo Tech, aqui é o [Nome da Pessoa 2]. Tudo o que a [Pessoa 1] prometeu para a diretoria foi implementado no código. Aqui na aba de Actions do GitHub, vocês podem ver nossos pipelines de CI/CD rodando. Toda vez que um código sobe, ele é validado, passa por testes de segurança (DevSecOps) e é empacotado no AWS ECR."

**💻 Ação no Terminal e Navegador:**
*(Rode `kubectl port-forward svc/argocd-server -n argocd 8080:443` e abra o ArgoCD).*

**FALA (Pessoa 2):**
> "Mas nós não deixamos o GitHub tocar no nosso cluster de produção. Nós adotamos o **GitOps** com o **ArgoCD**. O ArgoCD puxa automaticamente a versão segura do código e aplica no cluster Kubernetes. Como podem ver aqui, os corações verdes provam que o ambiente de produção está espelhado e saudável."

---

## 🟢 CENA 3: Demo Tech - Terraform e IaC (Evidência Financeira)
**🎙️ Pessoa 1** assume a palavra.
- **Objetivo:** Mostrar o Terraform e a criação baseada em Tags (FinOps).

**💻 Ação no VSCode e AWS:**
*(Mostre o arquivo `terraform/main.tf` focando no bloco `default_tags`, depois mostre a aba Tags do Banco RDS na AWS)*

**FALA (Pessoa 1):**
> "Toda essa infraestrutura, como o EKS, DynamoDB e SQS, foi subida via Terraform. Aqui está o nosso código declarativo. Notem este bloco de `default_tags`. Nós forçamos que todos os recursos recebam tags de Projeto, Ambiente e Centro de Custos. Na AWS, aqui no console do RDS, provamos que essas tags foram herdadas com sucesso, fechando o ciclo do FinOps que prometemos no Pitch."

---

## 🟢 CENA 4: Demo Tech - Observabilidade (Traces e Alertas)
**🎙️ Pessoa 2** assume a palavra.
- **Objetivo:** Mostrar as Golden Metrics, Dashboard SRE, Traces e Alertas.

**💻 Ação no Terminal e Navegador:**
*(Rode `kubectl port-forward svc/prometheus-grafana -n monitoring 8084:80` e abra o Grafana)*

**FALA (Pessoa 2):**
> "Por fim, para manter nosso SLA, precisamos de olhos na plataforma. Esta é a nossa stack de SRE rodando no Grafana. Aqui temos os Dashboards monitorando as **Golden Metrics**: uso de CPU, Memória, Latência e tráfego de rede (Traces). 
> 
> Baseado nos nossos SLOs, nós também configuramos **Alertas Ativos**. *(Abra a aba de Alerting do Grafana ou mostre o `prometheus-rules.yaml`)*. Se um serviço falhar, nosso fluxo de AIOps detecta a anomalia e notifica a equipe imediatamente via webhook antes que o usuário final perceba o impacto."

---

## 🟢 CENA 5: Demo Tech - DR na Prática e Encerramento
**(Pessoa 1 e Pessoa 2)**

**💻 Ação no AWS Console:**
*(Mostre as subnets na VPC ou as configurações do RDS mostrando Multi-AZ/Snapshots)*

**FALA (Pessoa 1):**
> "Para finalizar provando a nossa estratégia de Backup e DR que vendemos no Pitch: nossa rede foi criada abrangendo múltiplas zonas (`us-east-1a` e `us-east-1b`). E o nosso banco de dados tem retenção de backup ativa pela nuvem."

**FALA (Ambos):**
> "Nós estruturamos a base perfeita para um crescimento seguro e barato. Esse foi o projeto SolidaryTech para a Fase 5. Muito obrigado!" 🎬
