CREATE DATABASE Oficina;
USE Oficina;

CREATE TABLE Clientes (
  idClientes INT AUTO_INCREMENT PRIMARY KEY,
  Nome VARCHAR(45),
  Telefone VARCHAR(15),
  Endereco VARCHAR(100)
);

CREATE TABLE Veiculo (
  idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
  Placa VARCHAR(10),
  Modelo VARCHAR(45),
  Ano INT,
  Clientes_idClientes INT,
  FOREIGN KEY (Clientes_idClientes) REFERENCES Clientes(idClientes)
);

CREATE TABLE Mecanico (
  idMecanico INT AUTO_INCREMENT PRIMARY KEY,
  Nome_mecanico VARCHAR(45),
  Especialidade VARCHAR(45)
);

CREATE TABLE Servico (
  idServico INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(100),
  preco DECIMAL(10,2)
);

CREATE TABLE Equipe_mecanicos (
  idEquipe_mecanicos INT AUTO_INCREMENT PRIMARY KEY,
  Equipe_id INT,
  Mecanico_idMecanico INT,
  Servico_idServico INT,
  FOREIGN KEY (Mecanico_idMecanico) REFERENCES Mecanico(idMecanico),
  FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico)
);

CREATE TABLE Ordem_de_servico (
  idOrdem_de_servico INT AUTO_INCREMENT PRIMARY KEY,
  Data DATETIME,
  equipe_id INT,
  veiculo_id INT,
  status ENUM('Aberta', 'Em andamento', 'Concluída'),
  FOREIGN KEY (equipe_id) REFERENCES Equipe_mecanicos(idEquipe_mecanicos),
  FOREIGN KEY (veiculo_id) REFERENCES Veiculo(idVeiculo)
);

CREATE TABLE Peca (
  idPeca INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(45),
  preco DECIMAL(10,2),
  estoque INT
);

CREATE TABLE OS_Peca (
  idOS_Peca INT AUTO_INCREMENT PRIMARY KEY,
  peca_id INT,
  quantidade INT,
  FOREIGN KEY (peca_id) REFERENCES Peca(idPeca)
);

CREATE TABLE Ordem_de_servico_has_Servico (
  Ordem_de_servico_idOrdem_de_servico INT,
  Servico_idServico INT,
  PRIMARY KEY (Ordem_de_servico_idOrdem_de_servico, Servico_idServico),
  FOREIGN KEY (Ordem_de_servico_idOrdem_de_servico) REFERENCES Ordem_de_servico(idOrdem_de_servico),
  FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico)
);

CREATE TABLE OS_de_pecas (
  OS_Peca_idOS_Peca INT,
  Peca_idPeca INT,
  PRIMARY KEY (OS_Peca_idOS_Peca, Peca_idPeca),
  FOREIGN KEY (OS_Peca_idOS_Peca) REFERENCES OS_Peca(idOS_Peca),
  FOREIGN KEY (Peca_idPeca) REFERENCES Peca(idPeca)
);
INSERT INTO Clientes (Nome, Telefone, Endereco) VALUES
('Gabriel Souza', '11999999999', 'Rua das Palmeiras, 123'),
('Carlos Lima', '11888888888', 'Av. Central, 450');

INSERT INTO Veiculo (Placa, Modelo, Ano, Clientes_idClientes) VALUES
('ABC1234', 'Civic', 2018, 1),
('XYZ9876', 'Gol', 2015, 2);

INSERT INTO Mecanico (Nome_mecanico, Especialidade) VALUES
('João Silva', 'Motor'),
('Paulo Mendes', 'Elétrica');

INSERT INTO Servico (descricao, preco) VALUES
('Troca de óleo', 120.00),
('Revisão elétrica', 250.00);

INSERT INTO Equipe_mecanicos (Equipe_id, Mecanico_idMecanico, Servico_idServico) VALUES
(1, 1, 1),
(2, 2, 2);

INSERT INTO Ordem_de_servico (Data, equipe_id, veiculo_id, status) VALUES
('2025-10-08 10:00:00', 1, 1, 'Em andamento'),
('2025-10-07 09:00:00', 2, 2, 'Concluída');

INSERT INTO Peca (descricao, preco, estoque) VALUES
('Filtro de óleo', 45.00, 20),
('Cabo de vela', 30.00, 50);

INSERT INTO OS_Peca (peca_id, quantidade) VALUES
(1, 2),
(2, 4);

INSERT INTO Ordem_de_servico_has_Servico VALUES
(1, 1),
(2, 2);

INSERT INTO OS_de_pecas VALUES
(1, 1),
(2, 2);
-- 1. Listar todos os clientes e seus veículos
SELECT c.Nome, v.Placa, v.Modelo, v.Ano
FROM Clientes c
JOIN Veiculo v ON c.idClientes = v.Clientes_idClientes;

-- 2. Mostrar ordens de serviço e o status atual
SELECT os.idOrdem_de_servico, c.Nome, os.status, os.Data
FROM Ordem_de_servico os
JOIN Veiculo v ON os.veiculo_id = v.idVeiculo
JOIN Clientes c ON v.Clientes_idClientes = c.idClientes;

-- 3. Mostrar os serviços realizados por cada mecânico
SELECT m.Nome_mecanico, s.descricao, s.preco
FROM Mecanico m
JOIN Equipe_mecanicos em ON m.idMecanico = em.Mecanico_idMecanico
JOIN Servico s ON s.idServico = em.Servico_idServico;

-- 4. Mostrar peças usadas em cada OS
SELECT os.idOrdem_de_servico, p.descricao, op.quantidade
FROM Ordem_de_servico os
JOIN OS_Peca op ON os.idOrdem_de_servico = op.idOS_Peca
JOIN Peca p ON op.peca_id = p.idPeca;

-- 5. Total gasto em cada ordem de serviço
SELECT os.idOrdem_de_servico,
       SUM(s.preco + (p.preco * op.quantidade)) AS Total
FROM Ordem_de_servico os
JOIN Ordem_de_servico_has_Servico oss ON os.idOrdem_de_servico = oss.Ordem_de_servico_idOrdem_de_servico
JOIN Servico s ON oss.Servico_idServico = s.idServico
JOIN OS_Peca op ON os.idOrdem_de_servico = op.idOS_Peca
JOIN Peca p ON op.peca_id = p.idPeca
GROUP BY os.idOrdem_de_servico;
