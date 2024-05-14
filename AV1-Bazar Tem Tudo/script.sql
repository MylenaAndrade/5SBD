
-- Atualizando as colunas quant_total e preco_total
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

-- Inserindo as informações do pedido na tabela de movimentação de estoque
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

-- Verificando se o Item do Pedido possui estoque, se possuir é true se não false
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

-- Atualizando o estoque de um produto para o exemplo de caso tenha estoque
UPDATE produtos
SET estoque = 20
WHERE sku = 'SKU123';

-- Movendo os Pedidos caso tenha estoque marcar como concluido e excluir da tabela movimentacao, se não ser inseridos na tabela de compras
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

-- Preenchendo a coluna de estoque de acordo com os produtos que não possuia
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