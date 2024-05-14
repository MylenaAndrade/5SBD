-- Criando o Banco de Dados
CREATE DATABASE marketplace
COLLATE Latin1_General_CI_AI;

-- Acessando o BD criado
USE marketplace;

-- Criando a tabela Carga
CREATE TABLE tempCarga(
    pedido_id INT NOT NULL,
    item_pedido_id INT NOT NULL,
    dt_compra DATE NOT NULL,
    dt_pagamento DATE NOT NULL,
    email_cliente VARCHAR(20) NOT NULL,
    nome_cliente VARCHAR(20) NOT NULL,
    cpf_cliente VARCHAR(11) NOT NULL,
    tel_cliente VARCHAR(11) NOT NULL,
    sku VARCHAR(14) NOT NULL,
    upc VARCHAR(14) NOT NULL,
    nome_produto VARCHAR(30) NOT NULL,
    quant INT NOT NULL,
    moeda VARCHAR(10) NOT NULL,
    preco_item DECIMAL(6,2) NOT NULL,
    servico_envio VARCHAR(10) NOT NULL,
    endereco_entrega1 VARCHAR(40) NOT NULL,
    endereco_entrega2 VARCHAR(40) NULL,
    endereco_entrega3 VARCHAR(40) NULL,
    cidade_entrega VARCHAR(20) NOT NULL,
    estado_entrega VARCHAR(20) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    pais_entrega VARCHAR(10) NOT NULL
);


-- Criando a tabela clientes
CREATE TABLE clientes(
    cpf VARCHAR(11) PRIMARY KEY,
    email_cliente VARCHAR(20) NOT NULL,
    nome_cliente VARCHAR(20) NOT NULL,
    tel_cliente VARCHAR(11) NOT NULL
);

-- Criando a tabela produtos
CREATE TABLE produtos (
    sku VARCHAR(14) PRIMARY KEY,
    upc VARCHAR(14) NOT NULL,
    nome_produto VARCHAR(30) NOT NULL,
	estoque INT
);

-- Criando a tabela pedidos
CREATE TABLE pedidos (
    pedido_id INT NOT NULL PRIMARY KEY,
    dt_compra DATE NOT NULL,
    dt_pagamento DATE NOT NULL,
	status_pedido VARCHAR(14) DEFAULT 'Processando',
	preco_total decimal(6,2) default null,
    cliente_id VARCHAR(11),
    quant_total INT,
    moeda VARCHAR(10) NOT NULL,
    servico_envio VARCHAR(10) NOT NULL,
    endereco_entrega1 VARCHAR(40) NOT NULL,
    endereco_entrega2 VARCHAR(40) NULL,
    endereco_entrega3 VARCHAR(40) NULL,
    cidade_entrega VARCHAR(20) NOT NULL,
    estado_entrega VARCHAR(20) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    pais_entrega VARCHAR(10) NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cpf),
);

-- Criando a tabela itens pedido
CREATE TABLE itensPedido (
    item_pedido_id INT PRIMARY KEY,
    pedido_id INT,
    produto_id VARCHAR(14) NOT NULL,
	nome_produto VARCHAR(30) NOT NULL,
    quant INT NOT NULL,
    preco_item DECIMAL(6,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
	FOREIGN KEY (produto_id) REFERENCES produtos(sku)
);

-- Criando a tabela de movimentação de estoque
CREATE TABLE movimentacao_estoque (
    id INT PRIMARY KEY IDENTITY,
	pedido_id INT,
	quant_pedido INT,
	quant_estoque INT,
	dt_movimentacao DATETIME,
	preco_total INT,
	FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
);

-- Criando a tabela compras
CREATE TABLE compras (
    id INT PRIMARY KEY IDENTITY,
	dt_compra DATETIME,
	sku VARCHAR(14), 
	quant_necessaria INT,
);

