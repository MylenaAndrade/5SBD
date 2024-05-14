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