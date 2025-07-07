--visualizar a quantidade de registros de várias tabelas em uma única consulta
SELECT COUNT(*) as Qtd, 'Categorias' as Tabela FROM categorias
UNION ALL
SELECT COUNT(*) as Qtd, 'Clientes' as Tabela FROM clientes
UNION ALL
SELECT COUNT(*) as Qtd, 'Fornecedores' as Tabela FROM fornecedores
UNION ALL
SELECT COUNT(*) as Qtd, 'ItensVenda' as Tabela FROM itens_venda
UNION ALL
SELECT COUNT(*) as Qtd, 'Marcas' as Tabela FROM marcas
UNION ALL
SELECT COUNT(*) as Qtd, 'Produtos' as Tabela FROM produtos
UNION ALL
SELECT COUNT(*) as Qtd, 'Vendas' as Tabela FROM vendas;


-- Avaliar precos dos produtos
Begin TRANSACTION

UPDATE produtos
SET preco = CASE
    WHEN nome_produto = 'Bola de Futebol' THEN 50.00
    WHEN nome_produto = 'Chocolate' THEN 15.00
    WHEN nome_produto = 'Celular' THEN 2000.00
    WHEN nome_produto = 'Livro de Ficção' THEN 120.00
    WHEN nome_produto = 'Camisa' THEN 150.00
    ELSE preco
END

SELECT * from produtos

ROLLBACK

-----------

-- Avaliar o período que as vendas aconteceram 
--anual
SELECT * from vendas

SELECT strftime('%Y', data_venda) as data_vendas, COUNT(data_venda) as venda_anual from vendas
GROUP by data_vendas 
order by venda_anual desc

--mensal
SELECT strftime('%m', data_venda) as meses_vendas, COUNT(strftime('%m', data_venda)) as quantd from vendas 
where strftime('%Y', data_venda) = '2023'
GROUP by meses_vendas

-- Avaliar os últimos 3 meses de todos os anoscategorias

SELECT strftime('%Y', data_venda) as ano, strftime('%m', data_venda) as mes, count(id_venda) as vendas_total 
from vendas
where strftime('%m', data_venda) in ('01','11','12') 
group by ano,mes
order by ano,mes;

-- Avaliar as vendas feitas por cada fornecedor

SELECT * from vendas

SELECT f.nome, p.nome, COUNT(iv.produto_id) as qtd_produto_vendido from fornecedores f
join produtos p on f.id_fornecedor = p.fornecedor_id
join itens_venda iv on p.id_produto = iv.produto_id
group by iv.produto_id


SELECT f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
FROM itens_venda iv
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
GROUP BY Nome_Fornecedor

;
-- Avaliar no período da BlackFriday
SELECT strftime('%Y/%m', v.data_venda) AS "Ano/Mes",f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
FROM itens_venda iv
join vendas v on v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
where strftime('%m', v.data_venda) in ('11') 
GROUP BY Nome_Fornecedor
order by "Ano/mes",Nome_Fornecedor,Qtd_vendas desc
;

SELECT strftime('%Y/%m', v.data_venda) AS "Ano/Mes",f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
FROM itens_venda iv
join vendas v on v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
where strftime('%m', v.data_venda) in ('01','11','12') 
GROUP BY "Ano/Mes", Nome_Fornecedor
order by "Ano/Mes", Nome_Fornecedor;

-- Avaliar as vendas analisando a categoria

SELECT strftime('%Y', v.data_venda) as "Ano" ,c.nome_categoria, COUNT(iv.produto_id) as venda_total from categorias c
join produtos p on p.fornecedor_id = c.id_categoria
join itens_venda iv on iv.produto_id = p.id_produto
join vendas v on v.id_venda = iv.venda_id
GROUP by c.nome_categoria, "Ano"
order by "Ano", venda_total  desc;

-- Avaliar performance da NebulaNetwork (fornecedora)
select strftime('%Y/%m',v.data_venda) as "Ano/Mes" , COUNT(iv.produto_id) as Qtd_Vendas FROM fornecedores f
join produtos p on f.id_fornecedor = p.fornecedor_id
join itens_venda iv on iv.produto_id = p.id_produto
join vendas v on v.id_venda = iv.venda_id
where f.nome = 'NebulaNetworks'
GROUP by "Ano/Mes"
order by "Ano/Mes", Qtd_Vendas 

SELECT 'Ano/Mes',
	SUM(CASE WHEN Nome_Fornecedor=='NebulaNetworks' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_NebulaNetworks,
 	SUM(CASE WHEN Nome_Fornecedor=='HorizonDistributors' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_HorizonDistributors,
 	SUM(CASE WHEN Nome_Fornecedor=='AstroSupply' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_AstroSupply
 FROM(
   SELECT strftime('%Y/%m',v.data_venda) AS 'Ano/Mes', f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
   from fornecedores f
	join produtos p on f.id_fornecedor = p.fornecedor_id
	join itens_venda iv on iv.produto_id = p.id_produto
	join vendas v on v.id_venda = iv.venda_id
   WHERE f.nome='NebulaNetworks' OR f.nome='HorizonDistributors' OR f.nome='AstroSupply'
   GROUP BY Nome_Fornecedor, 'Ano/Mes'
   ORDER BY 'Ano/Mes' , Qtd_vendas
)
GROUP by 'Ano/Mes'


SELECT "Ano/Mes",
 SUM(CASE WHEN Nome_Fornecedor=='NebulaNetworks' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_NebulaNetworks,
 SUM(CASE WHEN Nome_Fornecedor=="'orizonDistributors' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_HorizonDistributors,
 SUM(CASE WHEN Nome_Fornecedor=='AstroSupply' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_AstroSupply
 FROM(
   SELECT strftime('%Y/%m',v.data_venda) AS "Ano/Mes", f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
   from fornecedores f
	join produtos p on f.id_fornecedor = p.fornecedor_id
	join itens_venda iv on iv.produto_id = p.id_produto
	join vendas v on v.id_venda = iv.venda_id
   WHERE f.nome='NebulaNetworks' OR f.nome='HorizonDistributors' OR f.nome='AstroSupply'
   GROUP BY Nome_Fornecedor, "Ano/Mes"
   ORDER BY "Ano/Mes" , Qtd_Vendas
  )
  GROUP BY "Ano/Mes"
 ;  
---------------------------------
   SELECT
    strftime('%Y/%m', v.data_venda) AS "Ano/Mes", -- Mudei para aspas duplas para o alias (melhor prática)
    f.nome AS Nome_Fornecedor,
    COUNT(iv.produto_id) AS Qtd_Vendas
FROM
    fornecedores f
JOIN
    produtos p ON f.id_fornecedor = p.fornecedor_id
JOIN
    itens_venda iv ON iv.produto_id = p.id_produto
JOIN
    vendas v ON v.id_venda = iv.venda_id
WHERE
    f.nome IN ('NebulaNetworks', 'HorizonDistributors', 'AstroSupply') -- Usando IN para mais clareza
GROUP BY
    Nome_Fornecedor,
    strftime('%Y/%m', v.data_venda) -- Agrupando pela expressão real do Ano/Mes
ORDER BY
    Nome_Fornecedor,
    strftime('%Y/%m', v.data_venda); -- Ordenando pela expressão real do Ano/Mes
    
    ----------------------
    
    
SELECT
    sub."Ano/Mes",
    SUM(CASE WHEN sub.Nome_Fornecedor = 'NebulaNetworks' THEN sub.Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_NebulaNetworks,
    SUM(CASE WHEN sub.Nome_Fornecedor = 'HorizonDistributors' THEN sub.Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_HorizonDistributors, 
    SUM(CASE WHEN sub.Nome_Fornecedor = 'AstroSupply' THEN sub.Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_AstroSupply
FROM (
  
    SELECT
        strftime('%Y/%m', v.data_venda) AS "Ano/Mes",
        f.nome AS Nome_Fornecedor,
        COUNT(iv.produto_id) AS Qtd_Vendas
    FROM
        fornecedores f
    JOIN
        produtos p ON f.id_fornecedor = p.fornecedor_id
    JOIN
        itens_venda iv ON iv.produto_id = p.id_produto
    JOIN
        vendas v ON v.id_venda = iv.venda_id
    WHERE
        f.nome IN ('NebulaNetworks', 'HorizonDistributors', 'AstroSupply') 
    GROUP BY
        "Ano/Mes", Nome_Fornecedor 
) AS sub 
GROUP BY
    sub."Ano/Mes"
ORDER BY
    sub."Ano/Mes"; 
    
    
    ----------------------------------
SELECT "Ano/Mes",
 SUM(CASE WHEN Nome_Fornecedor=='NebulaNetworks' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_NebulaNetworks,
 SUM(CASE WHEN Nome_Fornecedor=="'orizonDistributors' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_HorizonDistributors,
 SUM(CASE WHEN Nome_Fornecedor=='AstroSupply' THEN Qtd_Vendas ELSE 0 END) AS Qtd_Vendas_AstroSupply
 FROM(
   SELECT strftime('%Y/%m',v.data_venda) AS "Ano/Mes", f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
   from fornecedores f
	join produtos p on f.id_fornecedor = p.fornecedor_id
	join itens_venda iv on iv.produto_id = p.id_produto
	join vendas v on v.id_venda = iv.venda_id
   WHERE f.nome='NebulaNetworks' OR f.nome='HorizonDistributors' OR f.nome='AstroSupply'
   GROUP BY Nome_Fornecedor, "Ano/Mes"
   ORDER BY "Ano/Mes" , Qtd_Vendas
  )
  GROUP BY "Ano/Mes"
 ;  
 
 
 --------------------------
 
 -- Calculando percentual
 
 SELECT COUNT(venda_id) as Qtd_venda from itens_venda


SELECT nome_categoria, venda_total, ROUND(100*venda_total/( SELECT COUNT(venda_id) from itens_venda),3) || '%' as Porcentagem
From 
(
  SELECT c.nome_categoria, COUNT(iv.produto_id) as venda_total from categorias c
  join produtos p on c.id_categoria = p.categoria_id
  join itens_venda iv on iv.produto_id = p.id_produto
  join vendas v on v.id_venda = iv.venda_id
  GROUP by c.nome_categoria
  order by venda_total DESC
 );
 
 -- Porcentagem das Categorias

SELECT c.nome_categoria AS Nome_Categoria, COUNT(iv.produto_id) AS Qtd_Vendas
from itens_venda iv
JOIN vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN categorias c ON c.id_categoria = p.categoria_id
GROUP BY Nome_Categoria
ORDER BY Qtd_Vendas DESC
;

-- Porcentagem das Marcas

SELECT Nome_Marca, Qtd_Vendas, round(100.0 * Qtd_Vendas / (SELECT COUNT(*) FROM itens_venda), 2) || '%' AS Porcentagem
FROM(
    SELECT m.nome AS Nome_Marca, COUNT(iv.produto_id) AS Qtd_Vendas
    FROM itens_venda iv
    JOIN vendas v ON v.id_venda = iv.venda_id
    JOIN produtos p ON p.id_produto = iv.produto_id
    JOIN marcas m ON m.id_marca = p.marca_id
    GROUP BY Nome_Marca
    ORDER BY Qtd_Vendas DESC
    )
;

-- Porcentagem dos Fornecedores

SELECT COUNT(*) from itens_venda

SELECT Fnome, qtd_venda, round(100.0*qtd_venda/(SELECT COUNT(*) from itens_venda), 2) || '%' as porcentagem
from (
  SELECT f.nome Fnome, COUNT(iv.venda_id) qtd_venda from fornecedores f
  join produtos p on p.fornecedor_id = f.id_fornecedor
  join itens_venda iv on iv.produto_id = p.id_produto
  GROUP by f.nome
);


-- Quadro Geral
SELECT Mes, 
SUM(case when Ano == '2023' then Qtd_Vendas else 0 end) as '2023',
SUM(case when Ano == '2022' then Qtd_Vendas else 0 end) as '2022',
SUM(case when Ano == '2021' then Qtd_Vendas else 0 end) as '2021',
SUM(case when Ano == '2020' then Qtd_Vendas else 0 end) as '2020'
from 
(
SELECT strftime('%m', data_venda) AS Mes, strftime('%Y', data_venda) AS Ano, COUNT(*) AS Qtd_Vendas
FROM Vendas
GROUP BY Mes,Ano
ORDER BY Mes
)
group by Mes
---------
-- Avaliar a média da venda total nos anos 20,21 na BlackFriday
SELECT avg(qtd_venda) media_venda_anual 
from (
SELECT strftime('%Y', data_venda) as Ano, count(*) as qtd_venda from vendas v
where strftime('%m', data_venda) = '11' and Ano != '2022'
GROUP by Ano
);

-- Avaliar venda anual de 22

SELECT strftime('%Y', data_venda) as Ano, count(*) as qtd_venda from vendas v
where strftime('%m', data_venda) = '11' and Ano = '2022'
GROUP by Ano

-- Porcentagem comparando a media de vendas anual com as vendas de 22

-- WITH nome as (expressao) , nome as (expressao)

with media_vendas_anteriores as 
  (
  SELECT avg(qtd_venda) media_venda_anual 
  from (
  SELECT strftime('%Y', data_venda) as Ano, count(*) as qtd_venda from vendas v
  where strftime('%m', data_venda) = '11' and Ano != '2022'
  GROUP by Ano)
  ) 
  , vendas_atual as 
  (
  SELECT strftime('%Y', data_venda) as Ano, count(*) as qtd_venda from vendas v
  where strftime('%m', data_venda) = '11' and Ano = '2022'
  GROUP by Ano
  )
SELECT
  mva.media_venda_anual,
  va.qtd_venda,
  round((va.qtd_venda-mva.media_venda_anual)/mva.media_venda_anual*100.0,2) || '%'as porcentagem 
 from vendas_atual va, media_vendas_anteriores mva
  