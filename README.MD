 [![CI/CD - Build & Deploy](https://github.com/0isouza/desafio-devops/actions/workflows/deploy.yml/badge.svg) Edit 🖊️](https://github.com/0isouza/desafio-devops/actions/workflows/deploy.yml)

# **Desafio Prático – DevOps**

**Objetivo**

Este desafio explora a criatividade e limites da criação de soluções DevOps, instigando o desenvolvimento de aplicações, implementação de camadas de cache, observabilidade e automação. A entrega deve conter o código-fonte e o diagrama da infraestrutura.

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

# Estrutura do projeto e detalhamento da solução

**Estrutura do projeto:** O projeto será estruturado em dois principais diretórios: apps/ e infra/**.** O diretório **apps** conterá as aplicações e seus respectivos arquivos de configuração. A pasta **infra** abrangerá os arquivos para provisionamento da infraestrutura como código e também os deployments das aplicações desenvolvidas e ferramentas de observabilidade. O diretório **.github** terá o workflow definidos para automação CI/CD.

&nbsp;       ![467de202c5bc4a831177f7e036dcc36d.png](/C:/Users/igbarbos/AppData/Local/Programs/Joplin/resources/app.asar/_resources/467de202c5bc4a831177f7e036dcc36d.png)

**Aplicações:**

1.  ✅ Aplicação que retorna um **healthcheck** do servidor em **Python + Flask**, retornando um texto fixo ("Servidor OK!").
2.  ✅ Horário do servidor em **JavaScript + Node.js**, retornando o horário local.

**Infraestrutura:**

✅ Implantação de um cluster EKS via **Terraform,** que será orquestrado pelo **Kubernetes.**

**Cache:**

✅ Implantação do cache e proxy reverso através do **Nginx,** com as configurações orientadas (10s para a primeira aplicação, 1min para a segunda aplicação).

**Observabilidade**:

1.  ✅ Prometheus para coletar métricas do servidor e aplicações.
2.  ✅ Grafana para visualização dessas métricas e criar alertas.

&nbsp;
