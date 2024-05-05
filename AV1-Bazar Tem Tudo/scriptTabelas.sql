-- Criando o Banco de Dados
create database marketplace
default character set utf8mb4
default collate utf8mb4_general_ci;

-- Acessando o BD criado
use marketplace;

-- Criando a tabela Carga
create temporary table carga(
	pedido_id int not null,
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
create table clientes(
	cpf varchar(11) not null primary key,
    email_cliente varchar(20) not null,
    nome_cliente varchar(20) not null,
    tel_cliente varchar(11) not null
)default charset = utf8;

-- Retorna todos os cps da tabela e só insere se não tiver o cpf igual 
insert into clientes
select  c.cpf_cliente, c.email_cliente, c.nome_cliente, c.tel_cliente
from carga c
WHERE c.cpf_cliente NOT IN (SELECT cpf FROM clientes);

-- Criando a tabela produtos
 create table produtos (
    sku varchar(14) primary key,
    upc int not null,
    nome_produto varchar(20) not null
);

-- Retorna todos os produtos da tabela e só insere se não tiver o sku igual 
insert into produtos
select  c.sku, c.upc, c.nome_produto
from carga c
WHERE c.sku NOT IN (SELECT sku FROM produtos);

-- Verificando se a tabela foi preenchida corretamente
select * from produtos;

-- Criando a tabela pedido
create table pedidos(
	pedido_id int not null primary key,
    dt_compra date not null,
    dt_pagamento date not null,
    email_cliente varchar(20) not null,
    nome_cliente varchar(20) not null,
    cpf_cliente varchar(11) not null,
    tel_cliente varchar(13) not null,
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

-- Retorna todos os pedidos da tabela e só insere se não tiver o pedidos_id igual 
insert into pedidos
select  c.pedido_id, c.dt_compra, c.dt_pagamento, c.email_cliente, c.nome_cliente, c.cpf_cliente, c.tel_cliente, 
c.sku, c.upc, c.nome_produto, c.quant, c.moeda, c.preco_item, c.servico_envio, c.endereco_entrega1, c.endereco_entrega2,
c.endereco_entrega3, c.cidade_entrega, c.estado_entrega, c.cep, c.pais_entrega
from carga c
WHERE c.pedido_id NOT IN (SELECT pedido_id FROM pedidos);

-- Verificando se a tabela foi preenchida corretamente
select * from pedidos;

-- Criando a tabela itens pedido
create table itensPedido (
    item_pedido_id int,
    pedido_id int,
    sku varchar(14) not null,
    nome_produto varchar(20) not null,
    quant int not null,
    moeda varchar(10) not null,
    preco_item decimal(6,2) not null,
    foreign key (pedido_id) references pedidos(pedido_id)
)default charset = utf8;

-- Insere na tabela os dados da tabela carga e adiciona foreign key
insert into itensPedido
select c.item_pedido_id, p.pedido_id, c.sku, c.nome_produto, c.quant, c.moeda, c.preco_item
from carga c
INNER JOIN pedidos p ON p.pedido_id = c.pedido_id;

-- Verificando se a tabela foi preenchida corretamente
select * from itensPedido;