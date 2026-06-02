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
SELECT u.prezdivka, COUNT(c.autor_id) AS pocet_clanku
FROM uzivatele u
LEFT JOIN clanky c ON u.uzivatele_id = c.autor_id
GROUP BY u.uzivatele_id
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
DELIMITER  $
CREATE TRIGGER `check_title_length`
BEFORE INSERT ON `clanky`
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.titulek) < 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Titulek je příliš krátký!';
    END IF;
END $
DELIMITER ;

-- ---------------------------------------------------------------------------------
-- 9. ÚDRŽBA A ČIŠTĚNÍ
-- ---------------------------------------------------------------------------------
UPDATE uzivatele SET aktivni = 0 WHERE id = 3;
DELETE FROM uzivatele WHERE id = 2; -- Pozor: smaže i jeho články díky ON DELETE CASCADE!

-- ---------------------------------------------------------------------------------
-- 10. VAZBA M:N (MANY TO MANY)
-- ---------------------------------------------------------------------------------
-- Jeden článek může být ve více sekcích,
-- jedna sekce může obsahovat více článků.

CREATE TABLE IF NOT EXISTS `sekce`
(
    `id`    INT AUTO_INCREMENT PRIMARY KEY,
    `nazev` VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS `clanek_sekce`
(
    `clanek_id` INT,
    `sekce_id`  INT,
    PRIMARY KEY (`clanek_id`, `sekce_id`),

    FOREIGN KEY (`clanek_id`) REFERENCES `clanky` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`sekce_id`) REFERENCES `sekce` (`id`) ON DELETE CASCADE
);

-- Přiřazení článku do sekce
INSERT INTO clanek_sekce (clanek_id, sekce_id)
VALUES (1, 1);

-- Výpis článků v sekci
SELECT c.titulek, s.nazev
FROM clanky c
         JOIN clanek_sekce cs ON cs.clanek_id = c.id
         JOIN sekce s ON s.id = cs.sekce_id;

-- ---------------------------------------------------------------------------------
-- 11. PODDOTAZY (SUBQUERIES)
-- ---------------------------------------------------------------------------------

-- Články autora "Jan"
SELECT titulek
FROM clanky
WHERE autor_id = (SELECT id
                  FROM uzivatele
                  WHERE jmeno = 'Jan'
                  LIMIT 1);

-- Autor s nejvyšším počtem článků
SELECT u.jmeno,
       (SELECT COUNT(*)
        FROM clanky c
        WHERE c.autor_id = u.id) AS pocet_clanku
FROM uzivatele u
ORDER BY pocet_clanku DESC
LIMIT 1;

-- ---------------------------------------------------------------------------------
-- 12. TRANSAKCE
-- ---------------------------------------------------------------------------------
-- Použití například při převodu peněz.

START TRANSACTION;

UPDATE ucty
SET zustatek = zustatek - 1000
WHERE id = 1;

UPDATE ucty
SET zustatek = zustatek + 1000
WHERE id = 2;

COMMIT;

-- Při chybě:
-- ROLLBACK;

-- ---------------------------------------------------------------------------------
-- 13. INDEXY A OPTIMALIZACE
-- ---------------------------------------------------------------------------------

-- Vytvoření indexu pro rychlé vyhledávání
CREATE INDEX idx_email
    ON uzivatele (email);

-- Složený index
CREATE INDEX idx_jmeno_prijmeni
    ON uzivatele (jmeno, prijmeni);

-- ---------------------------------------------------------------------------------
-- 14. HAVING
-- ---------------------------------------------------------------------------------
-- HAVING filtruje až po GROUP BY.

SELECT autor_id,
       COUNT(*) AS pocet_clanku
FROM clanky
GROUP BY autor_id
HAVING pocet_clanku >= 2;

-- ---------------------------------------------------------------------------------
-- 15. ULOŽENÉ PROCEDURY
-- ---------------------------------------------------------------------------------

DELIMITER  $

CREATE PROCEDURE GetClanky()
BEGIN
    SELECT * FROM clanky;
END $

DELIMITER ;

-- Volání procedury
CALL GetClanky();

-- ---------------------------------------------------------------------------------
-- 16. PROCEDURY S PARAMETRY
-- ---------------------------------------------------------------------------------

DELIMITER  $

CREATE PROCEDURE GetClankyAutora(
    IN autor INT
)
BEGIN
    SELECT *
    FROM clanky
    WHERE autor_id = autor;
END $

DELIMITER ;

CALL GetClankyAutora(1);

-- ---------------------------------------------------------------------------------
-- 17. OUT A INOUT PARAMETRY
-- ---------------------------------------------------------------------------------

-- OUT parametr
DELIMITER  $

CREATE PROCEDURE PocetClankuAutora(
    IN autor INT,
    OUT pocet INT
)
BEGIN
    SELECT COUNT(*)
    INTO pocet
    FROM clanky
    WHERE autor_id = autor;
END $

DELIMITER ;

CALL PocetClankuAutora(1, @pocet);
SELECT @pocet;

-- INOUT parametr
DELIMITER  $

CREATE PROCEDURE ZvysHodnotu(
    INOUT cislo INT,
    IN navyseni INT
)
BEGIN
    SET cislo = cislo + navyseni;
END $

DELIMITER ;

SET @hodnota = 10;

CALL ZvysHodnotu(@hodnota, 5);

SELECT @hodnota;

-- ---------------------------------------------------------------------------------
-- 18. UŽITEČNÉ PŘÍKAZY
-- ---------------------------------------------------------------------------------

SHOW TABLES;

DESCRIBE uzivatele;

SHOW INDEX FROM uzivatele;

SHOW TRIGGERS;

SHOW PROCEDURE STATUS;

-- ---------------------------------------------------------------------------------
-- 19. MAZÁNÍ OBJEKTŮ
-- ---------------------------------------------------------------------------------

DROP VIEW IF EXISTS v_prehled_autoru;

DROP TRIGGER IF EXISTS check_title_length;

DROP PROCEDURE IF EXISTS GetClanky;

