-- =====================================================================
-- MySQL / MariaDB skript: andmebaas "kool"
-- Käivita:  sudo mysql < mysql.sql
-- Sisaldab: skeem + näidisandmed + päringud
-- Skeem on identne PostgreSQL omaga, v.a. automaatne id (AUTO_INCREMENT)
-- =====================================================================

-- 1) Andmebaas
CREATE DATABASE kool;
USE kool;

-- 2) Skeem (tabelid + veerud + andmetüübid)
CREATE TABLE klass (
    id      INT PRIMARY KEY,
    nimetus VARCHAR(10)
);

CREATE TABLE opilane (
    id             INT AUTO_INCREMENT PRIMARY KEY,  -- automaatne number (MySQL: AUTO_INCREMENT)
    nimi           VARCHAR(50),
    synniaeg       DATE,                            -- DATE väli
    keskmine_hinne DECIMAL(3,1),
    aktiivne       BOOLEAN,                         -- MySQL: salvestub tinyint(1) (1/0)
    klass_id       INT,
    FOREIGN KEY (klass_id) REFERENCES klass(id)
);

-- 3) Näidisandmed (samad mõlemas DBMS-is)
INSERT INTO klass (id, nimetus) VALUES (1, '10A'), (2, '11B');

INSERT INTO opilane (nimi, synniaeg, keskmine_hinne, aktiivne, klass_id) VALUES
('Mari Maasikas', '2008-04-15', 4.5, TRUE,  1),
('Jaan Tamm',     '2007-11-30', 3.8, TRUE,  2),
('Liis Lepik',    '2008-09-01', 4.2, FALSE, 1);

-- 4) Päringud (tagastavad tulemuse)
-- 4a) Kõik õpilased
SELECT * FROM opilane;

-- 4b) DATE-välja kasutav päring: enne 2008. aastat sündinud
SELECT nimi, synniaeg FROM opilane WHERE synniaeg < '2008-01-01';

-- 4c) JOIN: õpilane + tema klass
SELECT o.nimi, k.nimetus
FROM opilane o
JOIN klass k ON o.klass_id = k.id;

-- 5) Erinevuse demo: tõstutundlikkus
--    MySQL/MariaDB on vaikimisi tõstutundetu -> tagastab rea, kuigi kirjutasin väikeste tähtedega
SELECT * FROM opilane WHERE nimi = 'mari maasikas';
