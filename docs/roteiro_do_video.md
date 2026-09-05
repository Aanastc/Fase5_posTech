# 🎬 Roteiro de Gravação - Entregáveis da Fase 5 (Vídeos Separados)

Este roteiro atende **rigorosamente** a todos os requisitos do documento oficial `POSTECH - DCLT - Hackathon - Fase 5.pdf`. A apresentação foi desenhada para ser gravada de forma assíncrona por **duas pessoas**. 

---

# 📹 PARTE 1: Gravação da Pessoa 1
*(Foco: O Pitch Executivo, Fundação DevOps e FinOps/DR)*

## 🟢 CENA 1: O Pitch Executivo (Vendendo para a Diretoria)
- **Objetivo (PDF):** *Apresente a arquitetura, o PCN e as estratégias financeiras vendendo a viabilidade para a ONG.*

**FALA (Pessoa 1):** 
> "Olá, prezada diretoria da SolidaryTech, eu sou o(a) [Seu Nome]. Hoje apresentamos a nova plataforma de doações. Focamos em garantir viabilidade financeira, segurança e resiliência total.
> 
> Falando da nossa estratégia financeira (FinOps), adotamos *Rightsizing* no Kubernetes e o uso de Instâncias Spot, o que manteve nosso orçamento projetado extremamente enxuto. Além disso, criamos uma rigorosa Política de Tags no nosso código Terraform (`Project`, `Environment`, `CostCenter`), garantindo que cada centavo da infraestrutura seja justificado.
> 
> Sobre a Segurança e Continuidade de Negócios (PCN), nós não corremos riscos. Elaboramos um documento executivo de PCN com RTO de 1 hora e RPO de 15 minutos para os dados das doações. E se a AWS cair? Desenvolvemos uma estratégia prática de **Disaster Recovery (DR)** utilizando o conceito de Multi-AZ nativo da nuvem."

## 🟢 CENA 2: Demo Tech - Fundação DevOps e Evidências
- **Objetivo (PDF):** *Exiba o Terraform rodando (ou evidencie criação por tags) e demonstre o sistema de Backup/DR em ação.*

**💻 Ação Visual:**
*(Mostre a tela do arquivo `terraform/main.tf` focando nas `default_tags` e, em seguida, as subnets na AWS ou as tags do Banco)*

**FALA (Pessoa 1):**
> "Entrando na Demo Tech, nós cumprimos 100% dos requisitos da Fundação DevOps. Toda a nossa infraestrutura foi provisionada via **Infraestrutura como Código (IaC)** com o Terraform. Aqui no código, evidenciamos a criação dos recursos baseada nas Tags de FinOps, que são refletidas perfeitamente nos recursos da nuvem.
> 
> Evidenciando nosso **Disaster Recovery em ação**, aqui estão os módulos do nosso Terraform provisionando as redes e os bancos em múltiplas zonas de disponibilidade (`us-east-1a` e `us-east-1b`), além de configurarmos o backup de Snapshot automatizado do nosso RDS PostgreSQL para retenção externa de dados.
> 
> Agora, o(a) [Nome da Pessoa 2] vai demonstrar nossa esteira de CI/CD, GitOps e a parte de Monitoramento e AIOps."

*(Fim da gravação da Pessoa 1)*

---
---

# 📹 PARTE 2: Gravação da Pessoa 2
*(Foco: CI/CD, GitOps, SRE, APM e AIOps)*

## 🟢 CENA 3: Demo Tech - CI/CD e GitOps (ArgoCD)
- **Objetivo (PDF):** *Mostre os pipelines CI/CD rodando e o deploy no cluster via ArgoCD.*

**💻 Ação Visual:**
*(Mostre a tela do GitHub Actions rodando e depois abra o painel do ArgoCD com os corações verdes)*

**FALA (Pessoa 2):**
> "Dando continuidade, aqui é o(a) [Seu Nome]. Construímos nossos microsserviços em Docker e configuramos a esteira **CI/CD com DevSecOps**. Aqui na aba Actions do GitHub, mostramos nossos pipelines rodando com automação de testes e scanners de segurança.
> 
> Para o deploy, utilizamos **GitOps** através do **ArgoCD**. Ao invés de aplicarmos via `kubectl`, o ArgoCD garante a entrega contínua puxando o código direto do GitHub e aplicando de forma declarativa e segura no nosso cluster Kubernetes, como evidenciado pelo status Healthy da aplicação."

## 🟢 CENA 4: Demo Tech - Observabilidade, APM e Dashboard SRE
- **Objetivo (PDF):** *Mostre a rastreabilidade no APM (Traces), os alertas configurados e o Dashboard SRE com Golden Metrics e SLOs.*

**💻 Ação Visual:**
*(Mostre o Grafana nos gráficos de Workload/Pods para CPU/Memória, e a tela de Alerting do Prometheus/Grafana).*

**FALA (Pessoa 2):**
> "Na frente de Confiabilidade (SRE) e Observabilidade, nós implementamos a stack do Prometheus e Grafana.
> 
> Este é o nosso **Dashboard SRE**. Aqui monitoramos o serviço de doações calculando os nossos **SLOs** baseados nas **Golden Metrics**: estamos rastreando ativamente a Latência, a Taxa de Erros, e o uso de CPU e Memória para garantir o *Rightsizing*. A rastreabilidade das requisições (Traces/APM) nos permite identificar os gargalos da aplicação em tempo real.
> 
> Por fim, estruturamos uma gestão preditiva (ITSM/AIOps). Aqui estão nossos **Alertas configurados**. Se o Error Budget começar a ser consumido de forma anômala, o sistema dispara notificações automáticas, reduzindo drasticamente nosso tempo de resposta (MTTR)."

**FALA FINAL (Pessoa 2):**
> "Com todas essas frentes operando em conjunto, a SolidaryTech atinge o mais alto nível de maturidade operacional em nuvem exigido para a Fase 5. Muito obrigado!" 🎬

*(Fim da gravação da Pessoa 2)*
