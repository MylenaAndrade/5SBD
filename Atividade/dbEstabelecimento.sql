-- Criando o Banco de Dados
create database estabelecimento
default character set utf8mb4
default collate utf8mb4_general_ci;

-- Acessando o BD criado
use estabelecimento;

-- Criando a tabela Carga
create table carga(
	codigo_pedido int not null primary key,
	data_pedido date not null,
    sku varchar(14) not null,
    upc int not null,
    nome_produto varchar(20) not null,
    quant int not null,
    valor decimal(6,2) not null,
    frete decimal(5,2) not null,
    email varchar(20) not null,
    nome_comprador varchar(20) not null,
    endereco varchar(18) not null,
    uf varchar(2) not null,
    pais varchar(6) not null,
    cep varchar(9) not null
)default charset = utf8;

-- Inserindo dados na tabela Carga
INSERT INTO carga 
VALUES
(12345,'2024-04-25','SKU123',012345678901,'Camiseta Azul',2,25.00,5.00,'exemplo@email.com','João da Silva','Rua Exemplo, 123','SP','Brasil','01234-567'),
(54321,'2024-04-26','SKU456',123456789012,'Calça Jeans',1,50.00,7.00,'customer@example.com','Maria Oliveira','Av. Teste, 456','RJ','Brasil','89012-345'),
(98765,'2024-04-27','SKU789',234567890123,'Tênis Esportivo',3,80.00,10.00,'test@example.com','Carlos Souza','Rua Principal, 789','MG','Brasil','67890-123'),
(24680,'2024-04-28','SKU321',345678901234,'Boné Preto',4,15.00,6.00,'sales@example.com','Ana Santos','Av. Principal, 135','RS','Brasil','45678-901'),
(13579,'2024-04-29','SKU654',456789012345,'Jaqueta de Couro',1,120.00,12.00,'contact@example.com','Pedro Oliveira','Rua Secundária, 246','BA','Brasil','23456-789'),
(11223,'2024-04-30','SKU987',567890123456,'Sapato Social',2,90.00,8.00,'info@example.com','Fernanda Lima','Av. Exemplo, 789','PR','Brasil','34567-890'),
(99887,'2024-05-01','SKU101',678901234567,'Saia Floral',3,35.00,7.50,'support@example.com','Luiza Ferreira','Rua Teste, 567','SC','Brasil','12345-678'),
(55777,'2024-05-02','SKU202',789012345678,'Blusa Listrada',1,40.00,5.50,'info@example.com','Gustavo Almeida','Av. Principal, 987','PE','Brasil','98765-432'),
(33444,'2024-05-03','SKU303',890123456789,'Shorts Jeans',2,30.00,6.50,'hello@example.com','Mariana Silva','Rua Exemplo, 321','GO','Brasil','87654-321'),
(22112,'2024-05-04','SKU404',901234567890,'Vestido Estampado',1,55.00,8.50,'info@example.com','Laura Costa','Av. Teste, 123','CE','Brasil','76543-210');

