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

--VERIFICANDO SE EXISTE PROCEDURE JA CRIADA NA BASE DE DADOS
--SE TIVER A PROCEDURE NA BASE IRÁ APAGAR PARA CRIAR NOVAMENTE
IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_PREENCHER_CARGA')
	BEGIN
		DROP PROCEDURE SP_PREENCHER_CARGA
	END
GO

CREATE PROCEDURE SP_PREENCHER_CARGA
AS
	BULK INSERT tempCarga
	FROM 'C:/Users/mylen/OneDrive/Documentos/5SBD/AV1-Bazar Tem Tudo/carga.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',   
		FIRSTROW = 2         
	);
GO

EXEC SP_PREENCHER_CARGA;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_INSERIR_CLIENTES')
	BEGIN
		DROP PROCEDURE SP_INSERIR_CLIENTES
	END
GO

CREATE PROCEDURE SP_INSERIR_CLIENTES
AS
BEGIN
    DECLARE @cpf VARCHAR(11);
    DECLARE @email_cliente VARCHAR(20);
    DECLARE @nome_cliente VARCHAR(20);
    DECLARE @tel_cliente VARCHAR(11);

    -- Declara e abre o cursor para iterar sobre os clientes da carga
    DECLARE cur_clientes CURSOR FOR
    SELECT cpf_cliente, email_cliente, nome_cliente, tel_cliente
    FROM tempCarga;

    OPEN cur_clientes;
    FETCH NEXT FROM cur_clientes INTO @cpf, @email_cliente, @nome_cliente, @tel_cliente;

    -- Loop através dos clientes da carga
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verifica se o cliente já existe na tabela de clientes
        IF NOT EXISTS (SELECT 1 FROM clientes WHERE cpf = @cpf)
        BEGIN
            -- Insere o cliente na tabela de clientes se não existir
            INSERT INTO clientes (cpf, email_cliente, nome_cliente, tel_cliente)
            VALUES (@cpf, @email_cliente, @nome_cliente, @tel_cliente);
        END;

        -- Obtém o próximo cliente da carga
        FETCH NEXT FROM cur_clientes INTO @cpf, @email_cliente, @nome_cliente, @tel_cliente;
    END;

    -- Fecha o cursor
    CLOSE cur_clientes;
    DEALLOCATE cur_clientes;
END;
GO

EXEC SP_INSERIR_CLIENTES;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_INSERIR_PRODUTOS')
	BEGIN
		DROP PROCEDURE SP_INSERIR_PRODUTOS
	END
GO

CREATE PROCEDURE SP_INSERIR_PRODUTOS
AS
BEGIN
    DECLARE @sku VARCHAR(14);
    DECLARE @upc VARCHAR(14);
    DECLARE @nome_produto VARCHAR(30);

    -- Declara e abre o cursor para iterar sobre os produtos da carga
    DECLARE cur_produtos CURSOR FOR
    SELECT sku, upc, nome_produto
    FROM tempCarga;

    OPEN cur_produtos;
    FETCH NEXT FROM cur_produtos INTO @sku, @upc, @nome_produto;

    -- Loop através dos produtos da carga
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verifica se o produto já existe na tabela de produtos
        IF NOT EXISTS (SELECT 1 FROM produtos WHERE sku = @sku)
        BEGIN
            -- Insere o produto na tabela de produtos se não existir
            INSERT INTO produtos (sku, upc, nome_produto)
            VALUES (@sku, @upc, @nome_produto);
        END;

        -- Obtém o próximo produto da carga
        FETCH NEXT FROM cur_produtos INTO @sku, @upc, @nome_produto;
    END;

    -- Fecha o cursor
    CLOSE cur_produtos;
    DEALLOCATE cur_produtos;
END;
GO

EXEC SP_INSERIR_PRODUTOS;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_INSERIR_PEDIDOS')
	BEGIN
		DROP PROCEDURE SP_INSERIR_PEDIDOS
	END
GO

CREATE PROCEDURE SP_INSERIR_PEDIDOS
AS
BEGIN
    DECLARE @pedido_id INT;
    DECLARE @dt_compra DATE;
    DECLARE @dt_pagamento DATE;
	DECLARE @cliente_id VARCHAR(11);
    DECLARE @moeda VARCHAR(10);
    DECLARE @servico_envio VARCHAR(10);
    DECLARE @endereco_entrega1 VARCHAR(40);
    DECLARE @endereco_entrega2 VARCHAR(40);
    DECLARE @endereco_entrega3 VARCHAR(40);
    DECLARE @cidade_entrega VARCHAR(20);
    DECLARE @estado_entrega VARCHAR(20);
    DECLARE @cep VARCHAR(9);
    DECLARE @pais_entrega VARCHAR(10);

    -- Declara e abre o cursor para iterar sobre os pedidos da carga
    DECLARE cur_pedidos CURSOR FOR
    SELECT pedido_id, dt_compra, dt_pagamento,cpf_cliente, 
           moeda,servico_envio, 
           endereco_entrega1, endereco_entrega2, endereco_entrega3, cidade_entrega, 
           estado_entrega, cep, pais_entrega
    FROM tempCarga;

    OPEN cur_pedidos;
    FETCH NEXT FROM cur_pedidos INTO @pedido_id, @dt_compra, @dt_pagamento,@cliente_id,
                                      @moeda,@servico_envio,@endereco_entrega1, @endereco_entrega2, @endereco_entrega3, @cidade_entrega, 
                                      @estado_entrega, @cep, @pais_entrega;

    -- Loop através dos pedidos da carga
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verifica se o pedido já existe na tabela de pedidos
        IF NOT EXISTS (SELECT 1 FROM pedidos WHERE pedido_id = @pedido_id)
        BEGIN
            -- Insere o pedido na tabela de pedidos se não existir
            INSERT INTO pedidos (pedido_id, dt_compra, dt_pagamento,cliente_id,
                                 moeda,servico_envio, 
                                 endereco_entrega1, endereco_entrega2, endereco_entrega3, cidade_entrega, 
                                 estado_entrega, cep, pais_entrega)
            VALUES (@pedido_id, @dt_compra, @dt_pagamento, @cliente_id, @moeda, @servico_envio,
                    @endereco_entrega1, @endereco_entrega2, @endereco_entrega3, @cidade_entrega, 
                    @estado_entrega, @cep, @pais_entrega);
        END;

        -- Obtém o próximo pedido da carga
        FETCH NEXT FROM cur_pedidos INTO @pedido_id, @dt_compra, @dt_pagamento,@cliente_id,
                                          @moeda,@servico_envio, @endereco_entrega1, @endereco_entrega2, @endereco_entrega3, @cidade_entrega, 
                                          @estado_entrega, @cep, @pais_entrega;
    END;


	-- Fecha o cursor
    CLOSE cur_pedidos;
    DEALLOCATE cur_pedidos;
END;
GO

EXEC SP_INSERIR_PEDIDOS;


IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_ATUALIZANDO_TOTAL')
	BEGIN
		DROP PROCEDURE SP_ATUALIZANDO_TOTAL
	END
GO

CREATE PROCEDURE SP_ATUALIZANDO_TOTAL
AS
BEGIN
-- Atualiza a coluna quant_total com a soma da quantidade de cada pedido
	UPDATE pedidos
	SET quant_total = (SELECT SUM(quant) FROM tempCarga WHERE pedido_id = pedidos.pedido_id);

	-- Atualiza a coluna preco_total com o produto da quantidade total pelo preço do item
	UPDATE pedidos
	SET preco_total = (
		SELECT SUM(quant * preco_item)
		FROM tempCarga
		WHERE pedido_id = pedidos.pedido_id
	);
END
GO

EXEC SP_ATUALIZANDO_TOTAL;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_INSERIR_ITENS_PEDIDO')
	BEGIN
		DROP PROCEDURE SP_INSERIR_ITENS_PEDIDO
	END
GO

CREATE PROCEDURE SP_INSERIR_ITENS_PEDIDO
AS
BEGIN
    DECLARE @item_pedido_id INT;
    DECLARE @pedido_id INT;
    DECLARE @produto_id VARCHAR(14);
	DECLARE @nome_produto VARCHAR(30);
    DECLARE @quant INT;
    DECLARE @preco_item DECIMAL(6,2);

    -- Declara e abre o cursor para iterar sobre os itens de pedido da carga
    DECLARE cur_itens_pedido CURSOR FOR
    SELECT item_pedido_id, pedido_id, sku, nome_produto, quant, preco_item
    FROM tempCarga;

    OPEN cur_itens_pedido;
    FETCH NEXT FROM cur_itens_pedido INTO @item_pedido_id, @pedido_id, @produto_id, @nome_produto, @quant, @preco_item;

    -- Loop através dos itens de pedido da carga
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verifica se o item de pedido já existe na tabela de itensPedido
        IF NOT EXISTS (SELECT 1 FROM itensPedido WHERE item_pedido_id = @item_pedido_id)
        BEGIN
            -- Insere o item de pedido na tabela de itensPedido se não existir
            INSERT INTO itensPedido (item_pedido_id, pedido_id, produto_id, nome_produto, quant, preco_item)
            VALUES (@item_pedido_id, @pedido_id, @produto_id, @nome_produto,@quant, @preco_item);
        END;

        -- Obtém o próximo item de pedido da carga
        FETCH NEXT FROM cur_itens_pedido INTO @item_pedido_id, @pedido_id, @produto_id, @nome_produto,@quant, @preco_item;
    END;

    -- Fecha o cursor
    CLOSE cur_itens_pedido;
    DEALLOCATE cur_itens_pedido;
END;
GO

EXEC SP_INSERIR_ITENS_PEDIDO;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'SP_MOVIMENTAR_ESTOQUE')
	BEGIN
		DROP PROCEDURE SP_MOVIMENTAR_ESTOQUE
	END
GO

CREATE PROCEDURE SP_MOVIMENTAR_ESTOQUE
AS
BEGIN
    -- Declarando variáveis
    DECLARE @pedido_id INT;
    DECLARE @item_pedido_id INT;
    DECLARE @quant_pedido INT;
    DECLARE @sku VARCHAR(14);
    DECLARE @quant_estoque INT;
    DECLARE @preco_total INT;

    -- Cursor para iterar sobre os pedidos
    DECLARE cur_pedidos CURSOR FOR
    SELECT p.pedido_id, p.preco_total, i.item_pedido_id, p.quant_total, i.produto_id
    FROM pedidos p
    INNER JOIN itensPedido i ON p.pedido_id = i.pedido_id;

    OPEN cur_pedidos;
    FETCH NEXT FROM cur_pedidos INTO @pedido_id, @preco_total, @item_pedido_id, @quant_pedido, @sku;

    -- Iterando sobre os pedidos
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificando se já existe um registro para o mesmo pedido na tabela movimentacao_estoque
        IF NOT EXISTS (SELECT 1 FROM movimentacao_estoque WHERE pedido_id = @pedido_id)
        BEGIN
            -- Obtendo quantidade em estoque do produto
            SELECT @quant_estoque = estoque FROM produtos WHERE sku = @sku;

            -- Inserindo dados na tabela movimentacao_estoque
            INSERT INTO movimentacao_estoque (pedido_id, quant_pedido, quant_estoque, dt_movimentacao, preco_total)
            VALUES (@pedido_id, @quant_pedido, @quant_estoque, GETDATE(), @preco_total);
        END;

        -- Obtendo próximo registro do cursor
        FETCH NEXT FROM cur_pedidos INTO @pedido_id, @preco_total, @item_pedido_id, @quant_pedido, @sku;
    END;

    -- Fechando e desalocando o cursor
    CLOSE cur_pedidos;
    DEALLOCATE cur_pedidos;

	-- Ordenando os pedidos de forma decrescente com base no valor total
    SELECT *
    FROM movimentacao_estoque
    ORDER BY preco_total DESC;
END;



EXEC SP_MOVIMENTAR_ESTOQUE;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'VerificarEstoquePorPedido')
	BEGIN
		DROP PROCEDURE VerificarEstoquePorPedido
	END
GO

CREATE PROCEDURE VerificarEstoquePorPedido
AS
BEGIN
    -- Declarando variáveis
    DECLARE @pedido_id INT;
    DECLARE @produto_id VARCHAR(14);
    DECLARE @quant_pedido INT;
    DECLARE @estoque_disponivel INT;
    DECLARE @tem_estoque BIT;

    -- Cursor para iterar sobre os registros da tabela movimentacao_estoque
    DECLARE cur_pedidos CURSOR FOR
    SELECT m.pedido_id, i.produto_id, i.quant
    FROM movimentacao_estoque m
    INNER JOIN itensPedido i ON m.pedido_id = i.pedido_id;

    OPEN cur_pedidos;
    FETCH NEXT FROM cur_pedidos INTO @pedido_id, @produto_id, @quant_pedido;

    -- Iterando sobre os pedidos
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar o estoque disponível para o produto
        SELECT @estoque_disponivel = estoque
        FROM produtos
        WHERE sku = @produto_id;

        -- Verificar se há estoque suficiente para o pedido
        IF @estoque_disponivel >= @quant_pedido
            SET @tem_estoque = 1; -- TRUE
        ELSE
            SET @tem_estoque = 0; -- FALSE

       -- Atualizar a coluna quant_estoque na tabela movimentacao_estoque
        UPDATE movimentacao_estoque
        SET quant_estoque = CASE WHEN @estoque_disponivel >= @quant_pedido THEN 1 ELSE 0 END
        WHERE pedido_id = @pedido_id;

        -- Obter o próximo registro do cursor
        FETCH NEXT FROM cur_pedidos INTO @pedido_id, @produto_id, @quant_pedido;
    END;

    -- Fechar e desalocar o cursor
    CLOSE cur_pedidos;
    DEALLOCATE cur_pedidos;

	-- Ordenando os pedidos de forma decrescente com base no valor total
    SELECT *
    FROM movimentacao_estoque
    ORDER BY preco_total DESC;
END;


EXEC VerificarEstoquePorPedido;

UPDATE produtos
SET estoque = 20
WHERE sku = 'SKU123';

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'MoverPedidos')
	BEGIN
		DROP PROCEDURE MoverPedidos
	END
GO

CREATE PROCEDURE MoverPedidos
AS
BEGIN
    -- Atualizando o status dos pedidos com quant_estoque = 1 para "Concluído"
    UPDATE pedidos
    SET status_pedido = 'Concluído'
    WHERE pedido_id IN (
        SELECT pedido_id
        FROM movimentacao_estoque
        WHERE quant_estoque = 1
    );
	
	-- Descontando os itens vendidos do estoque na tabela produtos
    UPDATE produtos
    SET estoque = estoque - ip.quant
    FROM produtos p
    INNER JOIN itensPedido ip ON p.sku = ip.produto_id
    INNER JOIN movimentacao_estoque me ON ip.pedido_id = me.pedido_id
    WHERE me.quant_estoque = 1;

    -- Excluindo os registros da tabela movimentacao_estoque onde quant_estoque = 1
    DELETE FROM movimentacao_estoque
    WHERE quant_estoque = 1;

    -- Inserindo os pedidos com quant_estoque = 0 na tabela de compras
    INSERT INTO compras (dt_compra, sku, quant_necessaria)
    SELECT GETDATE(), ip.produto_id, ip.quant
    FROM itensPedido ip
    INNER JOIN movimentacao_estoque me ON ip.pedido_id = me.pedido_id
    WHERE me.quant_estoque = 0
    AND ip.produto_id NOT IN (SELECT sku FROM produtos WHERE estoque > 0);

    -- Ordenando os pedidos de forma decrescente com base no valor total
    SELECT *
    FROM movimentacao_estoque
    ORDER BY preco_total DESC;
END;

EXEC MoverPedidos;

IF EXISTS (SELECT 1 FROM SYS.OBJECTs WHERE TYPE = 'P' AND NAME = 'PreencherEstoqueProdutos')
	BEGIN
		DROP PROCEDURE PreencherEstoqueProdutos
	END
GO

CREATE PROCEDURE PreencherEstoqueProdutos
AS
BEGIN
    -- Criando uma tabela temporária para armazenar os dados do arquivo CSV
    CREATE TABLE #TempEstoque (
        sku VARCHAR(14) COLLATE DATABASE_DEFAULT PRIMARY KEY,
        estoque INT
    );

    -- Carregando os dados do arquivo CSV para a tabela temporária
    BULK INSERT #TempEstoque
    FROM 'C:/Users/mylen/OneDrive/Documentos/5SBD/AV1-Bazar Tem Tudo/estoque.csv'
    WITH (
        FIELDTERMINATOR = ';',  
        ROWTERMINATOR = '\n',   
        FIRSTROW = 2         
    );

    -- Atualizando a coluna estoque na tabela produtos com os dados da tabela temporária
    UPDATE p
    SET p.estoque = te.estoque
    FROM produtos p
    INNER JOIN #TempEstoque te ON p.sku = te.sku;

    -- Limpando a tabela temporária
    DROP TABLE #TempEstoque;
END;


EXEC PreencherEstoqueProdutos;


SELECT * FROM tempCarga;
SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM pedidos;
SELECT * FROM itensPedido;
SELECT * FROM movimentacao_estoque;
SELECT * FROM compras;
DROP TABLE clientes;
DROP TABLE produtos;
DROP TABLE pedidos;
DROP TABLE itensPedido;
DROP TABLE movimentacao_estoque;
DROP TABLE compras;
TRUNCATE TABLE tempCarga;
TRUNCATE TABLE clientes;
TRUNCATE TABLE produtos;
TRUNCATE TABLE pedidos;
TRUNCATE TABLE itensPedido;
TRUNCATE TABLE movimentacao_estoque;
TRUNCATE TABLE compras;

drop database marketplace;