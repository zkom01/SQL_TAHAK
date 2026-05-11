-- =================================================================================
-- KOMPLEXNÍ PRŮVODCE MYSQL: OD ZÁKLADŮ PO POKROČILOU LOGIKU
-- =================================================================================
-- Autor: [Tvé Jméno/Přezdívka]
-- Popis: Studijní materiál pokrývající DDL, DML, Joiny, Agregace a Triggery.

-- ---------------------------------------------------------------------------------
-- 1. NASTAVENÍ PROSTŘEDÍ
-- ---------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `vyuka_sql` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci;

USE `vyuka_sql`;

-- ---------------------------------------------------------------------------------
-- 2. TVORBA TABULEK (DDL) A REZERVACE MÍSTA
-- ---------------------------------------------------------------------------------
-- Tabulka uživatelů (Vazba 1:N na články)
CREATE TABLE IF NOT EXISTS `uzivatele` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `jmeno` VARCHAR(60) NOT NULL,
    `prijmeni` VARCHAR(60) NOT NULL,
    `email` VARCHAR(100) UNIQUE,
    `datum_narozeni` DATE,
    `aktivni` BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabulka článků
CREATE TABLE IF NOT EXISTS `clanky` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `autor_id` INT NOT NULL,
    `titulek` VARCHAR(255) NOT NULL,
    `obsah` TEXT,
    `publikovano` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`autor_id`) REFERENCES `uzivatele`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------------
-- 3. MANIPULACE S DATY (DML)
-- ---------------------------------------------------------------------------------
INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `email`, `datum_narozeni`) VALUES
('Jan', 'Novák', 'jan.novak@email.cz', '1990-05-15'),
('Petr', 'Svoboda', 'petr.s@seznam.cz', '1985-12-01'),
('Jana', 'Marná', 'jana.m@post.cz', '1995-07-20');

INSERT INTO `clanky` (`autor_id`, `titulek`, `obsah`) VALUES
(1, 'Úvod do MySQL', 'Obsah článku o databázích...'),
(1, 'Pokročilé JOINy', 'Jak efektivně spojovat tabulky...'),
(2, 'Proč používat Linux', 'Linux je skvělý operační systém...');

-- ---------------------------------------------------------------------------------
-- 4. DOTAZY, FILTROVÁNÍ A ŘAZENÍ
-- ---------------------------------------------------------------------------------
-- Výběr s podmínkou a logickými operátory
SELECT id, jmeno, prijmeni 
FROM uzivatele 
WHERE (datum_narozeni < '1995-01-01') AND aktivni = 1
ORDER BY prijmeni ASC;

-- Vyhledávání podle vzoru (LIKE)
SELECT * FROM uzivatele WHERE email LIKE '%@email.cz';

-- ---------------------------------------------------------------------------------
-- 5. AGREGAČNÍ FUNKCE A SESKUPOVÁNÍ (GROUP BY)
-- ---------------------------------------------------------------------------------
-- Kolik článků napsal každý autor?
SELECT u.prijmeni, COUNT(c.id) AS pocet_clanku
FROM uzivatele u
LEFT JOIN clanky c ON u.id = c.autor_id
GROUP BY u.id
HAVING pocet_clanku > 0;

-- ---------------------------------------------------------------------------------
-- 6. SPOJOVÁNÍ TABULEK (JOIN)
-- ---------------------------------------------------------------------------------
-- Vypíše titulky článků a k nim jména autorů
SELECT c.titulek, u.jmeno, u.prijmeni
FROM clanky c
INNER JOIN uzivatele u ON c.autor_id = u.id;

-- ---------------------------------------------------------------------------------
-- 7. POKROČILÉ FUNKCE: POHLEDY (VIEWS)
-- ---------------------------------------------------------------------------------
-- Vytvoření virtuální tabulky pro snadný přístup k statistikám
CREATE OR REPLACE VIEW `v_prehled_autoru` AS
SELECT jmeno, prijmeni, (SELECT COUNT(*) FROM clanky WHERE autor_id = uzivatele.id) as clanku
FROM uzivatele;

-- Použití pohledu
SELECT * FROM v_prehled_autoru WHERE clanku > 0;

-- ---------------------------------------------------------------------------------
-- 8. AUTOMATIZACE: TRIGGERY
-- ---------------------------------------------------------------------------------
-- Trigger, který před vložením článku zkontroluje délku titulku
DELIMITER //
CREATE TRIGGER `check_title_length`
BEFORE INSERT ON `clanky`
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.titulek) < 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Titulek je příliš krátký!';
    END IF;
END//
DELIMITER ;

-- ---------------------------------------------------------------------------------
-- 9. ÚDRŽBA A ČIŠTĚNÍ
-- ---------------------------------------------------------------------------------
-- UPDATE uzivatele SET aktivni = 0 WHERE id = 3;
-- DELETE FROM uzivatele WHERE id = 2; -- Pozor: smaže i jeho články díky ON DELETE CASCADE!

-- Konec souboru