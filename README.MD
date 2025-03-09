# **Desafio Prático – Analista DevOps Pleno**

&nbsp;

# Objetivo

Criar duas aplicações com rotas específicas, implementar cache com tempos de expiração diferentes, automatizar a infraestrutura, criar um diagrama arquitetural e sugerir melhorias, com o código e configurações armazenados em um repositório para avaliação.

&nbsp;

# Tarefas

1.  **Criar duas aplicações**
    1.  Utilize linguagens diferentes.
    2.  Cada aplicação deve ter duas rotas:
        1.  Uma retornando um texto fixo.
        2.  Outra retornando o horário atual do servidor.
2.  **Adicionar uma camada de cache,** as respostas das aplicações devem ser cacheadas por diferentes tempos de expiração.
    1.  A primeira aplicação deve ter um cache de **10 segundos**.
    2.  A segunda aplicação deve ter um cache de **1 minuto**.
3.  **Facilitar a execução**
    1.  A infraestrutura deve ser fácil de iniciar e rodar com o menor número de comandos possível.
4.  **Implementar observabilidade se possível**
5.  **Desenhar e analisar a infraestrutura**
    1.  Criar um diagrama representando a arquitetura.
6.  Identificar e sugerir pontos de melhoria.
7.  Atualizações
    1.  No desenho mostre como seriam fluxo de atualização de cada componente da infra e do código.
    2.  Identificar e sugerir pontos de melhoria.

**Entrega esperada**

- Código-fonte das aplicações e sua respectiva infra
- Configuração da camada de cache.
- Infraestrutura automatizada para fácil execução.
- Diagrama da infraestrutura com análise e sugestões de melhoria.
- Sempre bom manter as boas práticas e organização no Git

**Como entregar**

- Todo o conteúdo gerado no teste deve ser armazenado em um repositório de uma ferramenta de versionamento de código, esse repositório deve estar acessível para avaliação.

&nbsp;

# Proposta de solução:

**Aplicações:**

&nbsp;       1 - **Healthcheck** em **Python + Flask**, retornando um texto fixo ("Servidor OK!").  
        2 - Horário do servidor em **JavaScript + Node.js****,** retornando o horário local.

**Infraestrutura:**

&nbsp;       Servidor na EC2 com **Terraform** instalado para:

&nbsp;               1 - Implantar infraestrutura de cluster no **Kubernetes**;

**Cache:**

&nbsp;       Ainda em construção 🚧

**Observabilidade**:

&nbsp;       1 - Implementação do Prometheus e Grafana para coletar métricas do cluster e da aplicação.  
        2 - Definição de alerta para monitorar o consumo de CPU e memória da aplicação.  
<br/>**Desenho da infraestrutura**

&nbsp;       Ainda em construção **🚧**

**Próximos passos**

&nbsp;       **Melhoria no mostrador de horário do servidor:**

&nbsp;               - Ajustar o cache para que atualize com uma frequência maior, ex: de 5 em 5 segundos

&nbsp;               - Ou até mesmo atualizar as horas dinamicamente.

&nbsp;

# Prática

&nbsp;

### Passo 1: Desenvolver as aplicações e rodar localmente:

Instalação das dependências da app de **healthcheck**:

1.  Instalação do **flask**, que servirá o app via web: `pip install Flask`
2.  Rodar o app localmente: `python3 healthcheck.py`

&nbsp;

Instalação das dependências da app **mostrador de** horas:

1.  Instalação do **nodejs** e **npm** através do comando `sudo apt install nodejs npm`
2.  Instalação do **express**, que servirá o app via web: `npm install express`
3.  Iniciar o projeto através do `npm init -y`
4.  Rodar o app: `node index.js`

&nbsp;

### Passo 2: Implantar as aplicações usando Docker

1.  Instalar Docker na máquina na EC2: `sudo apt-get install docker.io`
2.  Garantir as permissões do Docker para o user atual: `sudo usermod -a -G docker $(whoami)`
3.  Aplicar as permissões de grupo sem deslogar: `newgrp docker`

&nbsp;

**App healthcheck**

1.  Criar arquivo **dockerfile**
    
2.  Construir a imagem docker: `docker build -t app-healthcheck .`
    
3.  Executar a imagem criada: `docker run -d -p 5000:5000 app-healthcheck`.
    

&nbsp;       Primeira aplicação rodando na porta 5000

&nbsp;       [imagem]

**App mostrador de hora**

1.  Criar arquivo **dockerfile**
2.  Construir a imagem docker: `docker build -t app-mostrador-horas .`
3.  Executar a imagem criada: `docker run -d -p 5001:5001 app-mostrador-horas`.

&nbsp;       Segunda aplicação rodando na porta 5001.

&nbsp;       [imagem]

&nbsp;

### Passo 3: Orquestrar containers em um cluster do Kubernetes

&nbsp;

Antes do nginx:

[imagem]

&nbsp;
