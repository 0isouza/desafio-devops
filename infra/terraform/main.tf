# Configuração do provedor AWS

provider "aws" {
  region = "us-east-1"  # Escolha a região que quer usar
}


# Definição das Variáveis

variable "cluster_name" {
  description = "Nome do cluster EKS"
  default     = "cluster-desafio"
}

variable "node_group_name" {
  description = "Nome do grupo de nós"
  default     = "node-group-desafio"
}

variable "instance_type" {
  description = "Tipo de instância EC2 dos nós"
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Número desejado de nós no cluster"
  default     = 1
}



# Criação da Role do IAM para o EKS

resource "aws_iam_role" "eks_role" {
  name = "eksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Criação do VPC com subnets, internet gateway e rotas

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# Subnets
resource "aws_subnet" "eks_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true  # Importante para os nós acessarem a internet
  
  tags = {
    Name = "${var.cluster_name}-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1  # Tag necessária para os balanceadores de carga
  }
}

# Tabela de rotas
resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.cluster_name}-route-table"
  }
}

# Associação da tabela de rotas às subnets
resource "aws_route_table_association" "eks_route_assoc" {
  count          = 2
  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.eks_route_table.id
}

# Grupo de segurança para o cluster EKS
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# Grupo de segurança para os nós EKS
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego entre nós - corrigido para usar protocolo ALL corretamente
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

resource "aws_security_group_rule" "nodes_to_cluster" {
  security_group_id        = aws_security_group.eks_nodes_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

# Criação da Role do IAM para os nós do EKS

resource "aws_iam_role" "node_role" {
  name = "eksNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_role_policy_1" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_role_policy_2" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_role_policy_3" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Criação do Cluster EKS

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.eks_subnets[*].id
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy,
    aws_internet_gateway.igw
  ]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id
  instance_types  = [var.instance_type]
  
  scaling_config {
    desired_size = var.desired_capacity
    min_size     = 1
    max_size     = 2
  }
  
  # Adicionar tags aos nós
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  # Garantir que as políticas necessárias estejam anexadas
  depends_on = [
    aws_iam_role_policy_attachment.node_role_policy_1,
    aws_iam_role_policy_attachment.node_role_policy_2,
    aws_iam_role_policy_attachment.node_role_policy_3,
  ]
}

# Saída com informações do cluster criado

output "cluster_endpoint" {
  description = "Endpoint para o servidor de API EKS"
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  description = "Nome do cluster criado"
  value = aws_eks_cluster.eks_cluster.name
}

output "config_map_aws_auth" {
  description = "Comando para obter o kubeconfig"
  value = "aws eks update-kubeconfig --region us-east-1 --name ${aws_eks_cluster.eks_cluster.name}"
}
