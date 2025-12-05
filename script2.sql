
CREATE DATABASE loja_homologacao;
\c loja_homologacao;


CREATE TABLE Marca (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Categoria (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Produto (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    marca_id INT REFERENCES Marca(id),
    categoria_id INT REFERENCES Categoria(id),
    preco DECIMAL(10,2) NOT NULL
);

CREATE TABLE Cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(200) UNIQUE
);

CREATE TABLE Venda (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES Cliente(id),
    data_venda DATE DEFAULT CURRENT_DATE,
    total DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE ItemVenda (
    id SERIAL PRIMARY KEY,
    venda_id INT REFERENCES Venda(id),
    produto_id INT REFERENCES Produto(id),
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2)
);


INSERT INTO Marca (nome) VALUES ('Teste');
INSERT INTO Categoria (nome) VALUES ('Teste');
INSERT INTO Produto (nome, marca_id, categoria_id, preco) VALUES
('Produto Teste', 1, 1, 100.00);

INSERT INTO Cliente (nome, email) VALUES
('Cliente Teste', 'teste@email.com');

INSERT INTO Venda (cliente_id) VALUES (1);


CREATE OR REPLACE FUNCTION atualizar_total_venda()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Venda 
    SET total = (
        SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
        FROM ItemVenda 
        WHERE venda_id = NEW.venda_id
    )
    WHERE id = NEW.venda_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_total_venda
    AFTER INSERT OR UPDATE OR DELETE ON ItemVenda
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_total_venda();


INSERT INTO ItemVenda (venda_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 3, 100.00);


CREATE VIEW resumo_vendas AS
SELECT 
    c.nome as cliente,
    COUNT(DISTINCT v.id) as total_compras,
    SUM(v.total) as total_gasto,
    STRING_AGG(p.nome, ', ') as produtos_comprados
FROM Cliente c
JOIN Venda v ON c.id = v.cliente_id
JOIN ItemVenda iv ON v.id = iv.venda_id
JOIN Produto p ON iv.produto_id = p.id
GROUP BY c.id, c.nome
ORDER BY total_gasto DESC;

TESTE 
SELECT * FROM resumo_vendas;
SELECT * FROM Venda;