-- CURSO SEGURANÇA MARIADB - BASE INICIAL
DROP DATABASE IF EXISTS empresa_seu_nome;
CREATE DATABASE empresa_seu_nome CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE empresa_seu_nome;

SET @chave_secreta = 'MinhaChave#2024Segura!'; -- GUARDAR EM LUGAR SEGURO

-- Tabela 1: Departamentos
CREATE TABLE departamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  sigla VARCHAR(10)
) ENGINE=InnoDB;

-- Tabela 2: Funcionarios (não deixar dados sensíveis em texto claro)
CREATE TABLE funcionarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  depto_id INT NOT NULL,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  cpf VARBINARY(255),                 
  cpf_criptografado VARBINARY(512),   
  telefone VARCHAR(30),
  salario DECIMAL(10,2),
  cargo VARCHAR(50),
  data_admissao DATE,
  CONSTRAINT fk_func_depto FOREIGN KEY (depto_id) REFERENCES departamentos(id)
) ENGINE=InnoDB;

-- Tabela 3: Projetos
CREATE TABLE projetos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  orcamento DECIMAL(15,2),
  data_inicio DATE
) ENGINE=InnoDB;

-- Tabela 4: Alocacao
CREATE TABLE alocacao (
  id INT AUTO_INCREMENT PRIMARY KEY,
  funcionario_id INT NOT NULL,
  projeto_id INT NOT NULL,
  horas_semanais INT NOT NULL,
  CONSTRAINT fk_aloc_func FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id),
  CONSTRAINT fk_aloc_proj FOREIGN KEY (projeto_id) REFERENCES projetos(id)
) ENGINE=InnoDB;

-- Tabelas de auditoria
CREATE TABLE auditoria_funcionarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usuario VARCHAR(255),
  acao ENUM('INSERT','UPDATE','DELETE'),
  funcionario_id INT,
  dados_antigos TEXT,
  dados_novos TEXT
) ENGINE=InnoDB;

-- Dados de exemplo (inserções seguras):
-- 1) Departamentos
INSERT INTO departamentos (nome, sigla) VALUES
  ('Tecnologia da Informação','TI'),
  ('Recursos Humanos','RH'),
  ('Financeiro','FIN'),
  ('Marketing','MKT'),
  ('Vendas','VND');

-- 2) Funcionários (exemplo: os CPFs são gravados criptografados, a coluna cpf visível fica NULL)
-- Observação: em produção, obtenha CPFs de forma segura e não deixe versão em texto claro.
INSERT INTO funcionarios (depto_id, nome, email, cpf, cpf_criptografado, telefone, salario, cargo, data_admissao) VALUES
  (1, 'Ana Silva', 'ana@empresa.com', NULL, AES_ENCRYPT('12345678901', @chave_secreta), '(11) 99999-8888', 8500.00, 'Gerente de TI', '2020-03-10'),
  (1, 'Bruno Santos', 'bruno@empresa.com', NULL, AES_ENCRYPT('98765432109', @chave_secreta), '(11) 98888-7777', 6500.00, 'Desenvolvedor', '2021-07-15'),
  (2, 'Carla Pereira', 'carla@empresa.com', NULL, AES_ENCRYPT('45678912345', @chave_secreta), '(11) 97777-6666', 5500.00, 'Analista RH', '2019-01-20'),
  (3, 'Diego Costa', 'diego@empresa.com', NULL, AES_ENCRYPT('17891234567', @chave_secreta), '(11) 96666-5555', 7200.00, 'Analista Financeiro', '2020-11-05'),
  (4, 'Elena Rodrigues', 'elena@empresa.com', NULL, AES_ENCRYPT('32165498732', @chave_secreta), '(11) 95655-4444', 4800.00, 'Marketing', '2022-06-18'),
  (5, 'Fernando Gomes', 'fernando@empresa.com', NULL, AES_ENCRYPT('65498732165', @chave_secreta), '(11) 94444-3333', 6800.00, 'Vendedor', '2021-09-22'),
  (1, 'Gabriela Martins', 'gabriela@empresa.com', NULL, AES_ENCRYPT('98732165498', @chave_secreta), '(11) 93333-2222', 5300.00, 'Analista de Sistemas', '2020-08-14');

-- 3) Projetos
INSERT INTO projetos (nome, orcamento, data_inicio) VALUES
  ('Sistema de Gestão', 120000.00, '2024-01-15'),
  ('Site Nova Empresa', 30000.00, '2024-02-01'),
  ('App Mobile', 150000.00, '2024-03-10');

-- 4) Alocações (horas_semanais)
INSERT INTO alocacao (funcionario_id, projeto_id, horas_semanais) VALUES
  (1, 1, 20),
  (2, 1, 30),
  (2, 3, 10),
  (5, 2, 25),
  (7, 3, 15);

-- Mensagem final de confirmação (consulta de controle)
SELECT 'Base de dados criada com sucesso!' AS mensagem;
SELECT 'ATENÇÃO: CPFs estão criptografados e a versão visível foi removida!' AS alerta;
SELECT 'Total de funcionários:' AS info, COUNT(*) AS quantidade FROM funcionarios;

-- QUERIES ÚTEIS (NÍVEIS LIMPOS E CORRIGIDOS)

-- Query 1.1: Ver todos os funcionários (atenção: não mostra CPF criptografado por padrão)
SELECT * FROM funcionarios;

-- Query 1.2: Ver funcionários por departamento
SELECT f.nome, f.cargo, d.nome AS departamento
FROM funcionarios f
JOIN departamentos d ON f.depto_id = d.id;

-- Query 1.3: Contar funcionários em cada departamento
SELECT d.nome, COUNT(f.id) AS total_funcionarios
FROM departamentos d
LEFT JOIN funcionarios f ON d.id = f.depto_id
GROUP BY d.nome
ORDER BY total_funcionarios DESC;

-- Nível 2: análise salarial por departamento
SELECT d.nome,
       ROUND(AVG(f.salario), 2) AS salario_medio,
       COUNT(f.id) AS qtd_funcionarios
FROM departamentos d
JOIN funcionarios f ON d.id = f.depto_id
GROUP BY d.nome
ORDER BY salario_medio DESC;

-- Nível 2.2: Top 5 maiores salários
SELECT nome, cargo, salario
FROM funcionarios
ORDER BY salario DESC
LIMIT 5;

-- Nível 2.3: Projetos e funcionários alocados
SELECT p.nome AS projeto,
       f.nome AS funcionario,
       a.horas_semanais,
       f.cargo
FROM projetos p
JOIN alocacao a ON p.id = a.projeto_id
JOIN funcionarios f ON a.funcionario_id = f.id
ORDER BY p.nome;

-- NÍVEL 3: Mostrar vulnerabilidade (exemplo seguro: CPF criptografado)
-- Mostrar somente CPF criptografado (varbinary ilegível) ou descriptografar com chave
SELECT nome, email, telefone, cpf, cpf_criptografado
FROM funcionarios
WHERE cpf IS NOT NULL OR cpf_criptografado IS NOT NULL;

-- Descriptografar (somente quem tiver a chave de sessão)
-- SET @chave_secreta = 'MinhaChave#2024Segura!';
SELECT nome,
       CAST(AES_DECRYPT(cpf_criptografado, @chave_secreta) AS CHAR) AS cpf_descriptografado
FROM funcionarios
WHERE cpf_criptografado IS NOT NULL;

-- NÍVEL 4: CONTROLE DE USUÁRIOS E PERMISSÕES (exemplos)
-- Observação: para executar CREATE USER / GRANT você precisa de privilégios de root/ADMIN
-- Substitua 'localhost' por host apropriado.

-- Usuário 1: gerente (acesso amplo ao schema)
-- (Atenção: em MariaDB ALTER USER/SET PASSWORD varia; o exemplo abaixo é genérico MySQL)
CREATE USER IF NOT EXISTS 'gerente_ti'@'localhost' IDENTIFIED BY 'Ger3nt3@2024!';
GRANT ALL PRIVILEGES ON empresa_seu_nome.* TO 'gerente_ti'@'localhost';
FLUSH PRIVILEGES;

-- Usuário 2: analista (somente SELECT)
CREATE USER IF NOT EXISTS 'analista_rh'@'localhost' IDENTIFIED BY 'Anal1st@2024!';
GRANT SELECT ON empresa_seu_nome.* TO 'analista_rh'@'localhost';
FLUSH PRIVILEGES;

-- Usuário 3: estagiário (apenas colunas não sensíveis)
CREATE USER IF NOT EXISTS 'estagiario'@'localhost' IDENTIFIED BY 'Est4gl@2024!';
GRANT SELECT (id, nome, cargo) ON empresa_seu_nome.funcionarios TO 'estagiario'@'localhost';
FLUSH PRIVILEGES;

-- NÍVEL 6: MASCARAMENTO — VIEW pública com dados mascarados
CREATE OR REPLACE VIEW funcionarios_publico AS
SELECT
  id,
  nome,
  -- mascarar email: primeira letra + resto oculto até @ + domínio
  CONCAT(LEFT(email,1),
         REPEAT('*', GREATEST(0, LEAST(6, LOCATE('@', email) - 2))),
         SUBSTRING(email, LOCATE('@', email))
  ) AS email_mascarado,
  -- mascarar telefone (ex.: (11) 9****-8888)
  CONCAT(LEFT(telefone, 4),
         REPEAT('*', GREATEST(0, LENGTH(telefone) - 8)),
         RIGHT(telefone, 4)
  ) AS telefone_mascarado,
  cargo,
  CASE
    WHEN salario IS NULL THEN 'Não informado'
    WHEN salario < 5000 THEN 'Até R$ 5.000'
    WHEN salario BETWEEN 5000 AND 8000 THEN 'R$ 5.000-8.000'
    ELSE 'Acima de R$ 8.000'
  END AS faixa_salarial
FROM funcionarios;

-- Conceder acesso à view para estagiário
GRANT SELECT ON empresa_seu_nome.funcionarios_publico TO 'estagiario'@'localhost';
FLUSH PRIVILEGES;

-- View para RH (acesso a CPF descriptografado não está automatizado em view por segurança)
-- Caso precise, a descriptografia deve ocorrer em aplicação com chave segura:
CREATE OR REPLACE VIEW funcionarios_rh AS
SELECT
  f.id,
  f.nome,
  -- NÃO incluir cpf em texto claro aqui por segurança; incluir cpf_criptografado/
  f.cpf_criptografado,
  f.email,
  f.telefone,
  f.cargo,
  f.salario,
  d.nome AS departamento
FROM funcionarios f
JOIN departamentos d ON f.depto_id = d.id;

-- Obs: para visualizar cpf em texto claro, o RH deve executar SELECT CAST(AES_DECRYPT(cpf_criptografado, @chave_secreta) AS CHAR) ... com a chave.

-- NÍVEL 7: AUDITORIA — TRIGGERS
-- Trigger AFTER INSERT
DELIMITER $$
CREATE TRIGGER audita_funcionario_insert
AFTER INSERT ON funcionarios
FOR EACH ROW
BEGIN
  INSERT INTO auditoria_funcionarios (usuario, acao, funcionario_id, dados_novos)
  VALUES (CURRENT_USER(), 'INSERT', NEW.id,
          CONCAT('NOVO: nome=', NEW.nome, '; email=', NEW.email, '; cargo=', NEW.cargo, '; salario=', NEW.salario));
END$$
DELIMITER ;

-- Trigger AFTER UPDATE
DELIMITER $$
CREATE TRIGGER audita_funcionario_update
AFTER UPDATE ON funcionarios
FOR EACH ROW
BEGIN
  INSERT INTO auditoria_funcionarios (usuario, acao, funcionario_id, dados_antigos, dados_novos)
  VALUES (CURRENT_USER(), 'UPDATE', NEW.id,
          CONCAT('ANTIGO: nome=', OLD.nome, '; salario=', OLD.salario, '; cargo=', OLD.cargo),
          CONCAT('NOVO: nome=', NEW.nome, '; salario=', NEW.salario, '; cargo=', NEW.cargo));
END$$
DELIMITER ;

-- Trigger AFTER DELETE
DELIMITER $$
CREATE TRIGGER audita_funcionario_delete
AFTER DELETE ON funcionarios
FOR EACH ROW
BEGIN
  INSERT INTO auditoria_funcionarios (usuario, acao, funcionario_id, dados_antigos)
  VALUES (CURRENT_USER(), 'DELETE', OLD.id,
          CONCAT('EXCLUIDO: nome=', OLD.nome, '; cpf_criptografado=', HEX(OLD.cpf_criptografado)));
END$$
DELIMITER ;

-- NÍVEL 8: VALIDAÇÃO (BEFORE INSERT) — exemplo de trigger para validar e formatar
DELIMITER $$
CREATE TRIGGER valida_funcionario_insert
BEFORE INSERT ON funcionarios
FOR EACH ROW
BEGIN
  -- Validar formato simples de email
  IF NEW.email IS NOT NULL AND (NEW.email NOT LIKE '%_@_%._%') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido';
  END IF;

  -- Validar salário mínimo de exemplo (ajuste se necessário)
  IF NEW.salario IS NOT NULL AND NEW.salario < 1412.00 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salário abaixo do mínimo legal (exemplo)';
  END IF;

  -- Normalizar telefone: retirar espaços extras 
  IF NEW.telefone IS NOT NULL THEN
    SET NEW.telefone = REPLACE(REPLACE(REPLACE(NEW.telefone, ' ', ''), '.', ''), '-', '');
  END IF;
END$$
DELIMITER ;

-- Exemplos de testes de inserção para validação
-- Deve falhar (email inválido)
-- INSERT INTO funcionarios (depto_id,nome,email,salario) VALUES (1,'Teste','emailinvalido',1500.00);
-- Deve falhar (salario baixo)
-- INSERT INTO funcionarios (depto_id,nome,email,salario) VALUES (1,'Teste','teste@ex.com',1000.00);

-- NÍVEL 9: CONSULTAS DE MONITORAMENTO
-- Dashboard simples (contagens)
SELECT 'Funcionários' AS categoria, COUNT(*) AS total FROM funcionarios
UNION ALL
SELECT 'CPFs Criptografados', COUNT(*) FROM funcionarios WHERE cpf_criptografado IS NOT NULL
UNION ALL
SELECT 'Eventos de Auditoria', COUNT(*) FROM auditoria_funcionarios
UNION ALL
SELECT 'Views de Segurança', COUNT(*) FROM information_schema.views WHERE table_schema = 'empresa_seu_nome';

-- Atividades últimas 24h
SELECT DATE(data_hora) AS data,
       HOUR(data_hora) AS hora,
       usuario,
       acao,
       COUNT(*) AS quantidade
FROM auditoria_funcionarios
WHERE data_hora >= NOW() - INTERVAL 1 DAY
GROUP BY DATE(data_hora), HOUR(data_hora), usuario, acao
ORDER BY data DESC, hora DESC;

-- Verificar CPFs ainda visíveis (dever ser zero)
SELECT 'CPFs ainda visíveis' AS problema, COUNT(*) AS quantidade FROM funcionarios WHERE cpf IS NOT NULL
UNION ALL
SELECT 'Funcionários sem email', COUNT(*) FROM funcionarios WHERE email IS NULL OR email = ''
UNION ALL
SELECT 'Salários abaixo de 2000', COUNT(*) FROM funcionarios WHERE salario < 2000;

-- NÍVEL 10: MANUTENÇÃO (backups, limpeza)
-- Backup dos CPFs criptografados 
CREATE TABLE IF NOT EXISTS backup_criptografia AS
SELECT id, nome, cpf_criptografado, SHA2(@chave_secreta,256) AS hash_chave, NOW() AS data_backup
FROM funcionarios
WHERE cpf_criptografado IS NOT NULL;

-- Limpeza de objetos de teste
-- DROP USER IF EXISTS 'gerente_ti'@'localhost';
-- DROP USER IF EXISTS 'analista_rh'@'localhost';
-- DROP USER IF EXISTS 'estagiario'@'localhost';

-- Fim do script
