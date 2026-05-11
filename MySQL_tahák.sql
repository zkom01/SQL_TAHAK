# MySQL Tahák - Základní i pokročilé operace

# Vytvoření a smazání databáze
CREATE DATABASE `databaze_pro_web` CHARACTER SET utf8 COLLATE utf8_czech_ci;
DROP DATABASE `databaze_pro_web`;

# Vytvoření a smazání tabulky
CREATE TABLE uzivatele (
     uzivatele_id INT NOT NULL AUTO_INCREMENT,
     jmeno VARCHAR(60) NOT NULL,
     prijmeni VARCHAR(60) NOT NULL,
     datum_narozeni DATE NOT NULL,
     pocet_clanku INT NULL DEFAULT NULL,
     PRIMARY KEY (uzivatele_id)
);
DROP TABLE `uzivatele`;

# Vkládání dat
INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `datum_narozeni`, `pocet_clanku`)
VALUES ('Jan', 'Novák', '1984-11-03', 17);

INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `datum_narozeni`, `pocet_clanku`)
VALUES ('Tomáš', 'Marný', '1989-02-01', 6),
       ('Josef', 'Nový', '1972-12-20', 9),
       ('Michaela', 'Slavíková', '1990-08-14', 1);

# Mazání a aktualizace dat
DELETE FROM `uzivatele` WHERE `uzivatele_id` = 2;

DELETE FROM `uzivatele`
WHERE (`jmeno` = 'Jan' AND `datum_narozeni` >= '1980-1-1') OR (`pocet_clanku` < 3);

UPDATE `uzivatele`
SET `prijmeni` = 'Dolejší', `pocet_clanku` = `pocet_clanku` + 1
WHERE `uzivatele_id` = 4;

TRUNCATE TABLE `uzivatele`; # Vymaže data a resetuje auto_increment

# Výběr dat a vyhledávání (SELECT)
SELECT * FROM uzivatele WHERE jmeno = 'Jan';

SELECT prijmeni, pocet_clanku FROM uzivatele WHERE jmeno = 'Jan';

# Filtrování (WHERE, LIKE, BETWEEN)
SELECT * FROM uzivatele WHERE datum_narozeni >= '1960-01-01' AND pocet_clanku > 5;
SELECT * FROM uzivatele WHERE prijmeni LIKE 's%'; # Začíná na S
SELECT prijmeni FROM uzivatele WHERE prijmeni LIKE '_o___'; # Druhé písmeno O, celkem 5 znaků
SELECT jmeno, prijmeni, datum_narozeni FROM uzivatele WHERE datum_narozeni BETWEEN '1980-01-01' AND '1989-12-31';

# Řazení a limity
SELECT jmeno, prijmeni FROM uzivatele ORDER BY prijmeni;
SELECT jmeno, prijmeni, pocet_clanku FROM uzivatele ORDER BY pocet_clanku DESC, prijmeni LIMIT 10;

# Agregační funkce
SELECT COUNT(*) FROM uzivatele WHERE pocet_clanku > 0;
SELECT AVG(pocet_clanku) FROM uzivatele;
SELECT SUM(pocet_clanku) FROM uzivatele WHERE datum_narozeni > '1980-01-01';
SELECT MIN(datum_narozeni) FROM uzivatele;
SELECT MAX(pocet_clanku) FROM uzivatele;

# Seskupování (GROUP BY)
SELECT jmeno, COUNT(*) AS pocet FROM uzivatele GROUP BY jmeno ORDER BY jmeno;

# Práce s více tabulkami (JOIN)
CREATE TABLE uzivatele_rozsirene (
    uzivatele_id INT NOT NULL AUTO_INCREMENT,
    prezdivka VARCHAR(155),
    email VARCHAR(155),
    heslo VARCHAR(255),
    PRIMARY KEY (uzivatele_id)
);

CREATE TABLE clanky (
    clanky_id INT AUTO_INCREMENT,
    autor_id INT,
    titulek VARCHAR(155),
    obsah TEXT,
    publikovano DATETIME,
    PRIMARY KEY (clanky_id)
);

# INNER JOIN (pouze záznamy s protějškem)
SELECT clanky.titulek, uzivatele_rozsirene.prezdivka
FROM clanky
INNER JOIN uzivatele_rozsirene ON autor_id = uzivatele_id;

# LEFT JOIN (všechny články i ty bez autora)
SELECT clanky.titulek, uzivatele_rozsirene.prezdivka
FROM clanky
LEFT JOIN uzivatele_rozsirene ON autor_id = uzivatele_id;

# Poddotazy (Subqueries)
SELECT c.titulek FROM clanky AS c
WHERE c.autor_id = (SELECT u.uzivatele_id FROM uzivatele_rozsirene AS u WHERE u.prezdivka = 'David' LIMIT 1);

# Změna struktury tabulky (ALTER)
ALTER TABLE `clanky` ADD COLUMN `zhlidnuti` INT;
ALTER TABLE `clanky` MODIFY COLUMN `zhlidnuti` BIGINT;
ALTER TABLE `clanky` DROP COLUMN `zhlidnuti`;
ALTER TABLE `clanky` ADD INDEX (`titulek`);

# Transakce
START TRANSACTION;
UPDATE `ucty` SET `zustatek` = `zustatek` - 100 WHERE `id` = 1;
UPDATE `ucty` SET `zustatek` = `zustatek` + 100 WHERE `id` = 2;
COMMIT;

# Pohledy (Views)
CREATE VIEW `clanky_2024` AS
SELECT titulek, publikovano FROM clanky WHERE publikovano >= '2024-01-01';

# Klauzule HAVING (filtrování po seskupení)
SELECT mesto, COUNT(*) AS pocet_zakazniku
FROM zakaznici
GROUP BY mesto
HAVING pocet_zakazniku > 1;

# Triggery (Spouště)
DELIMITER $
CREATE TRIGGER before_insert_pobocky BEFORE INSERT ON pobocky FOR EACH ROW
BEGIN
    UPDATE statistika SET celkovy_pocet = celkovy_pocet + NEW.pocet_pracovniku;
END$
DELIMITER ;