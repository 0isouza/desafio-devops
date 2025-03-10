# Documentação - Prática das atividades realizadas

### Passo 1: Desenvolver as aplicações e rodar localmente:

Dependências e desenvolvimento do app de **healthcheck**:

1.  Instalação do **flask**, que servirá o app via web: `pip install Flask`
2.  Rodar o app localmente na porta 5000: `python3 healthcheck.py`

```py
from flask import Flask

app = Flask(__name__)

@app.route('/healthcheck', methods=['GET'])
def health_check():
    # Retorno da mensagem de healthcheck
    return "Servidor OK!"

if __name__ == '__main__':
    # Configuração para  '0.0.0.0', para permitir acessos de qualquer endereço IP
    app.run(host='0.0.0.0', port=5000)
```

&nbsp;

Dependências e desenvolvimento do app **mostrador de** horas:

1.  Instalação do **nodejs** e **npm** através do comando `sudo apt install nodejs npm`
2.  Instalação do **express**, que servirá o app via web: `npm install express`
3.  Iniciar o projeto através do `npm init -y`
4.  Rodar o app na porta 5001: `node index.js`

```js
// Importa o módulo express
const express = require('express');
const app = express();
const port = 5001;

// Rota para retornar a hora atual do servidor
app.get('/hora', (req, res) => {
    const dataAtual = new Date();
    const horaAtual = dataAtual.toLocaleTimeString();
    res.send(`Hora atual do servidor: ${horaAtual}`);
});

// Inicia o servidor
app.listen(port, () => {
    console.log(`Servidor rodando na porta ${port}`);
});
```

&nbsp;

### Passo 2: Implantar as aplicações usando Docker

1.  Instalar Docker na máquina na EC2: `sudo apt-get install docker.io`
2.  Garantir as permissões do Docker para o user atual: `sudo usermod -a -G docker $(whoami)`
3.  Aplicar as permissões de grupo sem deslogar: `newgrp docker`

&nbsp;**Implantação do App healthcheck**

1.  Criar arquivo **dockerfile**
    
2.  Construir a imagem docker: `docker build -t app-healthcheck .`
    
3.  Executar a imagem criada: `docker run -d -p 5000:5000 app-healthcheck`.
    

&nbsp;       Primeira aplicação rodando na porta 5000

&nbsp;       ![ed1019887f1124e0206c98bc2b12a8ff.png](../_resources/ed1019887f1124e0206c98bc2b12a8ff.png)

&nbsp;**Implantação do app mostrador de hora**

1.  Criar arquivo **dockerfile**
2.  Construir a imagem docker: `docker build -t app-mostrador-horas .`
3.  Executar a imagem criada: `docker run -d -p 5001:5001 app-mostrador-horas`.

&nbsp;       Segunda aplicação rodando na porta 5001.

&nbsp;       ![d04532cc0a70ab6fe2d376ac333745d1.png](../_resources/d04532cc0a70ab6fe2d376ac333745d1.png)

&nbsp;

### Passo 3: Subir os containers em um cluster do Kubernetes

1.  Preparar credenciais e instalar ferramentas:
    1.  Criar credencial de acesso no IAM e anotar os dados da Acess Key.
    2.  Instalar o AWS CLI se não tiver instalado ainda.
    3.  Configurar a AWS CLI através do comando: `aws configure`, na região desejada (us-east-1)
    4.  Instalar o **kubectl** e **terraform**.
2.  Implantar o cluster usando o `terraform apply`.
3.  Aplicar os recursos **.yaml** usando o `kubectl apply -f .`.

Saída do `terraform plan`:

![57af7b2d1415d74c45fab4c38e5f683d.png](../_resources/57af7b2d1415d74c45fab4c38e5f683d.png)

Saída do `kubectl apply -f .`:

![6eb1e48bff85806a19bcdf4bdb4834ff.png](../_resources/6eb1e48bff85806a19bcdf4bdb4834ff.png)

&nbsp;

**Passo 4: Implantar CI/CD para automatizar o deployment**

1.  Configurar as secrets do repositório (AWS Access Key, região, e URIs das imagens no ECR).
2.  Ajustar o Workflow no GitHub Actions

Configuração das secrets:

**<img src="../_resources/37cc23421c263711831046cefd3ecf98.png" alt="37cc23421c263711831046cefd3ecf98.png" width="694" height="303">**

Deploys automatizados:

**<img src="../_resources/5b3cff1632e0d5c37e8dfb962a4682df.png" alt="5b3cff1632e0d5c37e8dfb962a4682df.png" width="703" height="330">**

&nbsp;

**Passo 5: Deploy da observabilidade usando Prometheus + Grafana**

1.  Criação dos arquivos **grafana-deployment.yaml** e **prometheus-deployment.yaml**
2.  Atualização do **ConfigMap** do Nginx, para mapear o redirecionamento para as ferramentas.
3.  Implementar ferramentas através do `kubectl apply -f grafana-deployment.yaml` e `kubectl apply -f prometheus-deployment.yaml`
4.  Se necessário, reiniciar Nginx através do `kubectl rollout restart deployment nginx-proxy`.

&nbsp;

&nbsp;

&nbsp;

# Destruir recursos criados

Destruir recursos do Kubernetes **antes** de destruir o cluster: `kubectl delete -f .`

Destruir infra criada pelo terraform (cluster): `terraform destroy`

&nbsp;

&nbsp;
