-- Criando o Banco de Dados
create database marketplace
default character set utf8mb4
default collate utf8mb4_general_ci;

-- Acessando o BD criado
use marketplace;

-- Criando a tabela Carga
create temporary table carga(
	pedido_id int not null primary key,
	item_pedido_id int not null,
    dt_compra date not null,
    dt_pagamento date not null,
    email_cliente varchar(20) not null,
    nome_cliente varchar(20) not null,
    cpf_cliente varchar(11) not null,
    tel_cliente varchar(11) not null,
    sku varchar(14) not null,
    upc int not null,
    nome_produto varchar(18) not null,
    quant int not null,
    moeda varchar(10) not null,
    preco_item decimal(6,2) not null,
    servico_envio varchar(10) not null,
    endereco_entrega1 varchar(40) not null,
    endereco_entrega2 varchar(40) default null,
    endereco_entrega3 varchar(40) default null,
    cidade_entrega varchar(20) not null,
    estado_entrega varchar(20) not null,
    cep varchar(9) not null,
    pais_entrega varchar(10) not null
)default charset = utf8;

-- Carregando o arquivo csv para a tabela
LOAD DATA INFILE 'C:/Users/mylen/OneDrive/Documentos/5SBD/AV1-Bazar Tem Tudo/carga.csv'
INTO TABLE carga
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verificando se o arquivo csv foi incluido corretamente
select * from carga;

-- Criando a tabela clientes
create table cliente(
	cpf varchar(11) not null primary key,
    email_cliente varchar(20) not null,
    nome_cliente varchar(20) not null,
    tel_cliente varchar(11) not null
)default charset = utf8;

-- Retorna todos os cps da tabela e só insere se não tiver o cpf igual 
insert into cliente
select  c.cpf_cliente, c.email_cliente, c.nome_cliente, c.tel_cliente
from carga c
WHERE c.cpf_cliente NOT IN (SELECT cpf FROM cliente);


