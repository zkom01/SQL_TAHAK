-- ============================================================
--  MySQL TAHÁK / UČEBNÍ POMŮCKA
-- ============================================================
--  OBSAH:
--    1.  Databáze – vytvoření, smazání
--    2.  Tabulky – vytvoření, smazání, přehled datových typů
--    3.  Modifikátory sloupců (NOT NULL, AUTO_INCREMENT …)
--    4.  INSERT – vkládání dat
--    5.  UPDATE – aktualizace dat
--    6.  DELETE / TRUNCATE – mazání dat
--    7.  SELECT – výběr dat, podmínky WHERE
--    8.  Operátory LIKE, BETWEEN, IN
--    9.  ORDER BY, LIMIT
--   10.  Agregační funkce (COUNT, SUM, AVG, MIN, MAX)
--   11.  GROUP BY + HAVING
--   12.  JOIN (INNER, LEFT, RIGHT)
--   13.  Aliasy tabulek a sloupců
--   14.  Poddotazy (subqueries)
--   15.  ALTER TABLE – změna struktury
--   16.  Transakce (START TRANSACTION, COMMIT, ROLLBACK)
--   17.  Pohledy (VIEW)
--   18.  Indexy a optimalizace
--   19.  Fulltext vyhledávání
--   20.  Triggery
--   21.  Uložené procedury a funkce
--   22.  Cizí klíče (FOREIGN KEY)
--   23.  Uživatelé a oprávnění
-- ============================================================


-- ============================================================
-- 1. DATABÁZE
-- ============================================================

-- Vytvoření databáze (utf8 + české řazení)
CREATE DATABASE `moje_db` CHARACTER SET utf8 COLLATE utf8_czech_ci;

-- Smazání databáze
DROP DATABASE `moje_db`;


-- ============================================================
-- 2. TABULKY
-- ============================================================

-- Vytvoření tabulky
CREATE TABLE `uzivatele`
(
    uzivatele_id   INT          NOT NULL AUTO_INCREMENT,
    jmeno          VARCHAR(60)  NOT NULL,
    prijmeni       VARCHAR(60)  NOT NULL,
    datum_narozeni DATE         NOT NULL,
    pocet_clanku   INT          NULL DEFAULT NULL,
    PRIMARY KEY (uzivatele_id)
);

-- Vytvoření tabulky jen pokud NEEXISTUJE (bezpečnější)
CREATE TABLE IF NOT EXISTS `logy`
(
    log_id  INT  NOT NULL AUTO_INCREMENT PRIMARY KEY,
    zprava  TEXT NOT NULL
);

-- Smazání tabulky
DROP TABLE `uzivatele`;

-- ---- Přehled datových typů ----
/*
  ČÍSLA
    TINYINT      -128 … 127  (nebo 0 … 255 UNSIGNED)
    SMALLINT     -32 768 … 32 767
    MEDIUMINT
    INT          -2 147 483 648 … 2 147 483 647
    BIGINT
    FLOAT / DOUBLE / DECIMAL(m,d)  – desetinná čísla

  TEXT
    CHAR(n)      pevná délka, max. 255 znaků
    VARCHAR(n)   proměnná délka, max. 65 535 B
    TINYTEXT     max. 255 B
    TEXT         max. 64 KB
    MEDIUMTEXT   max. 16 MB
    LONGTEXT     max. 4 GB

  DATUM A ČAS
    DATE         'RRRR-MM-DD'
    TIME         'HH:MM:SS'
    DATETIME     'RRRR-MM-DD HH:MM:SS'
    TIMESTAMP    jako DATETIME, ale do roku 2038 – raději nepoužívat

  OSTATNÍ
    BLOB         binární data (obrázky apod.)
    BOOLEAN      alias pro TINYINT(1); 0 = FALSE, 1 = TRUE
*/


-- ============================================================
-- 3. MODIFIKÁTORY SLOUPCŮ
-- ============================================================
/*
  NOT NULL          – hodnota nesmí být NULL
  NULL              – hodnota může být NULL (výchozí)
  DEFAULT hodnota   – výchozí hodnota při vložení bez uvedení sloupce
  AUTO_INCREMENT    – automaticky zvyšující se číslo (jen pro INT/BIGINT)
  UNIQUE            – hodnoty musí být v celém sloupci unikátní
  PRIMARY KEY       – primární klíč (automaticky UNIQUE + NOT NULL)
*/


-- ============================================================
-- 4. INSERT – vkládání dat
-- ============================================================

-- Vložení jednoho záznamu
INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `datum_narozeni`, `pocet_clanku`)
    VALUE ('Jan', 'Novák', '1984-11-03', 17);

-- Vložení více záznamů najednou (výkonnější než opakovaný INSERT)
INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `datum_narozeni`, `pocet_clanku`)
VALUES ('Tomáš', 'Marný',     '1989-02-01', 6),
       ('Josef', 'Nový',      '1972-12-20', 9),
       ('Michaela', 'Slavíková', '1990-08-14', 1);


-- ============================================================
-- 5. UPDATE – aktualizace dat
-- ============================================================

-- VŽDY uvádět WHERE, jinak se změní VŠECHNY řádky!
UPDATE `uzivatele`
SET `prijmeni`     = 'Dolejší',
    `pocet_clanku` = `pocet_clanku` + 1   -- aritmetika v SET je OK
WHERE `uzivatele_id` = 4;

-- Aktualizace více řádků najednou (podmínka vrátí více záznamů)
UPDATE `vozidla`
SET `max_rychlost` = 320
WHERE `max_rychlost` > 320;


-- ============================================================
-- 6. DELETE a TRUNCATE – mazání dat
-- ============================================================

-- Smazání konkrétního záznamu
DELETE FROM `uzivatele`
WHERE `uzivatele_id` = 2;

-- Smazání více záznamů podle podmínky
DELETE FROM `uzivatele`
WHERE (`jmeno` = 'Jan' AND `datum_narozeni` >= '1980-01-01')
   OR (`pocet_clanku` < 3);

-- TRUNCATE: smaže VŠECHNA data a resetuje AUTO_INCREMENT
--   (rychlejší než DELETE bez WHERE, nelze vrátit transakcí)
TRUNCATE TABLE `uzivatele`;


-- ============================================================
-- 7. SELECT – výběr dat a podmínky WHERE
-- ============================================================

-- Výběr všech sloupců
SELECT * FROM `uzivatele`;

-- Výběr konkrétních sloupců
SELECT `jmeno`, `prijmeni` FROM `uzivatele`;

-- Podmínka – rovnost
SELECT * FROM `uzivatele`
WHERE `jmeno` = 'Jan';

-- Podmínka – porovnání + logický AND
SELECT * FROM `uzivatele`
WHERE `datum_narozeni` >= '1960-01-01'
  AND `pocet_clanku` > 5;

-- Podmínka – logický OR
SELECT * FROM `uzivatele`
WHERE `jmeno` = 'Jan'
   OR `jmeno` = 'Eva';

-- NULL hodnoty
SELECT * FROM `uzivatele` WHERE `pocet_clanku` IS NULL;
SELECT * FROM `uzivatele` WHERE `pocet_clanku` IS NOT NULL;


-- ============================================================
-- 8. LIKE, BETWEEN, IN
-- ============================================================

-- LIKE – vzorové hledání
--   %  = libovolný počet libovolných znaků
--   _  = přesně jeden libovolný znak
SELECT * FROM `uzivatele` WHERE `prijmeni` LIKE 's%';       -- začíná na S
SELECT * FROM `uzivatele` WHERE `prijmeni` LIKE '_o___';    -- 5 znaků, 2. písmeno o
SELECT * FROM `uzivatele` WHERE `prijmeni` LIKE '%ová%';    -- obsahuje "ová"

-- BETWEEN – rozsah (včetně krajních hodnot)
SELECT * FROM `uzivatele`
WHERE `datum_narozeni` BETWEEN '1980-01-01' AND '1989-12-31';

-- IN – výčet hodnot (alternativa k několika OR)
SELECT * FROM `uzivatele`
WHERE `uzivatele_id` IN (2, 3, 4);

SELECT * FROM `vozidla`
WHERE `nazev` IN ('Sáně', 'Moped', 'Pickup');

-- NOT IN – vše MIMO výčet
SELECT * FROM `bank_account`
WHERE `bank_code` NOT IN (SELECT `bank_code` FROM `bank_code`);


-- ============================================================
-- 9. ORDER BY a LIMIT
-- ============================================================

-- Řazení vzestupně (ASC = výchozí)
SELECT `jmeno`, `prijmeni` FROM `uzivatele`
ORDER BY `prijmeni`;

-- Řazení sestupně
SELECT `jmeno`, `prijmeni`, `pocet_clanku` FROM `uzivatele`
ORDER BY `pocet_clanku` DESC;

-- Řazení podle více sloupců
SELECT `jmeno`, `prijmeni`, `pocet_clanku` FROM `uzivatele`
ORDER BY `pocet_clanku` DESC, `prijmeni` ASC;

-- LIMIT – omezení počtu výsledků
SELECT `jmeno`, `prijmeni` FROM `uzivatele`
ORDER BY `pocet_clanku` DESC
LIMIT 10;

-- LIMIT s OFFSET (přeskočí prvních N záznamů – užitečné pro stránkování)
SELECT * FROM `uzivatele`
LIMIT 10 OFFSET 20;   -- záznamy 21–30


-- ============================================================
-- 10. AGREGAČNÍ FUNKCE
-- ============================================================

-- COUNT – počet řádků (splňujících podmínku)
SELECT COUNT(*) FROM `uzivatele` WHERE `pocet_clanku` > 0;

-- SUM – součet
SELECT SUM(`pocet_clanku`) FROM `uzivatele`
WHERE `datum_narozeni` > '1980-01-01';

-- AVG – průměr
SELECT AVG(`pocet_clanku`) FROM `uzivatele`;

-- MIN / MAX
SELECT MIN(`datum_narozeni`) FROM `uzivatele`;
SELECT MAX(`pocet_clanku`)   FROM `uzivatele`;

-- ⚠️  POZOR: MIN/MAX s dalšími sloupci nefunguje správně!
--   Místo:  SELECT `jmeno`, MIN(`datum_narozeni`) FROM `uzivatele`;
--   Použij: ORDER BY + LIMIT 1
SELECT `jmeno`, `prijmeni`, `datum_narozeni` FROM `uzivatele`
ORDER BY `datum_narozeni`
LIMIT 1;


-- ============================================================
-- 11. GROUP BY + HAVING
-- ============================================================

-- GROUP BY – seskupení řádků (nutné při kombinaci s agregacemi)
SELECT `jmeno`, COUNT(*) AS `pocet`
FROM `uzivatele`
GROUP BY `jmeno`
ORDER BY `jmeno`;

-- Pořadí klauzulí:
--   SELECT … FROM … WHERE … GROUP BY … HAVING … ORDER BY … LIMIT …

-- HAVING – filtrování SKUPIN (obdoba WHERE, ale pro agregované výsledky)
--   WHERE filtruje řádky PŘED seskupením
--   HAVING filtruje skupiny PO seskupení

SELECT `id_objednavky`,
       SUM(`pocet_kusu`)                  AS `kusy`,
       SUM(`pocet_kusu` * `cena_za_kus`)  AS `cena_celkem`
FROM `detail_objednavky`
GROUP BY `id_objednavky`
HAVING `cena_celkem` > 100
   AND `kusy` > 10;

-- Kombinace WHERE (filtr řádků) + GROUP BY + HAVING (filtr skupin)
SELECT `mesto`, COUNT(*) AS `pocet_zakazniku`
FROM `zakaznik`
WHERE `vek` > 17                    -- filtruje PŘED seskupením
GROUP BY `mesto`
HAVING `pocet_zakazniku` > 1;       -- filtruje PO seskupení


-- ============================================================
-- 12. JOIN – dotazy přes více tabulek
-- ============================================================

-- Schéma příkladu:
--   clanky.autor_id  ↔  uzivatele.uzivatele_id

-- INNER JOIN – průnik (jen záznamy s párem v obou tabulkách)
SELECT `c`.`titulek`, `u`.`prezdivka`
FROM `clanky` AS `c`
         INNER JOIN `uzivatele` AS `u` ON `c`.`autor_id` = `u`.`uzivatele_id`
ORDER BY `u`.`prezdivka`;

-- LEFT JOIN – všechny záznamy z LEVÉ tabulky + páry z pravé
--   (pokud pár chybí → NULL)
SELECT `c`.`titulek`, `u`.`prezdivka`
FROM `clanky` AS `c`
         LEFT JOIN `uzivatele` AS `u` ON `c`.`autor_id` = `u`.`uzivatele_id`;
-- → zobrazí i článek bez existujícího autora (prezdivka = NULL)

-- RIGHT JOIN – všechny záznamy z PRAVÉ tabulky + páry z levé
SELECT `c`.`titulek`, `u`.`prezdivka`
FROM `clanky` AS `c`
         RIGHT JOIN `uzivatele` AS `u` ON `c`.`autor_id` = `u`.`uzivatele_id`;
-- → zobrazí i uživatele bez článků (titulek = NULL)

-- ⚠️  Nikdy nepropojovat tabulky přes WHERE (tzv. „WHERE-ování") – výkon + nejasnost!
--   ŠPATNĚ:  SELECT ... FROM clanky, uzivatele WHERE autor_id = uzivatele_id;
--   SPRÁVNĚ: SELECT ... FROM clanky JOIN uzivatele ON ...;

-- JOIN přes 3 tabulky (komentáře + uživatelé + články)
SELECT `u`.`prezdivka`, `k`.`obsah`, `c`.`titulek`
FROM `komentare` AS `k`
         JOIN `uzivatele` AS `u` ON `u`.`uzivatele_id` = `k`.`uzivatel_id`
         JOIN `clanky`    AS `c` ON `c`.`clanky_id`    = `k`.`clanek_id`
ORDER BY `k`.`datum`;


-- ============================================================
-- 13. ALIASY
-- ============================================================

-- Alias sloupce (AS je nepovinné, ale doporučené pro čitelnost)
SELECT COUNT(*) AS `pocet_uzivatelu` FROM `uzivatele`;

-- Alias tabulky (zkracuje zápis v JOIN dotazech)
SELECT `u`.`prezdivka`, `c`.`titulek`
FROM `uzivatele` AS `u`
         JOIN `clanky` AS `c` ON `c`.`autor_id` = `u`.`uzivatele_id`;


-- ============================================================
-- 14. PODDOTAZY (SUBQUERIES)
-- ============================================================

-- Poddotaz v WHERE – vrací jednu hodnotu
SELECT `c`.`titulek`
FROM `clanky` AS `c`
WHERE `c`.`autor_id` = (
    SELECT `u`.`uzivatele_id`
    FROM `uzivatele` AS `u`
    WHERE `u`.`prezdivka` = 'David'
    LIMIT 1
);

-- Poddotaz s IN – vrací více hodnot
SELECT `c`.`titulek`
FROM `clanky` AS `c`
WHERE `c`.`autor_id` IN (
    SELECT `u`.`uzivatele_id`
    FROM `uzivatele` AS `u`
    WHERE `u`.`prezdivka` = 'David'
);

-- Korelovaný poddotaz v SELECT (počet článků pro každého uživatele)
SELECT `u`.`prezdivka`,
       (SELECT COUNT(*)
        FROM `clanky` AS `c`
        WHERE `c`.`autor_id` = `u`.`uzivatele_id`) AS `pocet_clanku`
FROM `uzivatele` AS `u`
ORDER BY `pocet_clanku` DESC;

-- NOT EXISTS – záznamy bez páru
SELECT `u`.`prezdivka`
FROM `uzivatele` AS `u`
WHERE NOT EXISTS (
    SELECT * FROM `clanky` AS `c`
    WHERE `c`.`autor_id` = `u`.`uzivatele_id`
);

-- ALL – porovnání se VŠEMI hodnotami poddotazu
SELECT `k`.`obsah`, `k`.`datum`
FROM `komentare` AS `k`
WHERE `k`.`datum` > ALL (
    SELECT `k2`.`datum`
    FROM `komentare` AS `k2`
             JOIN `uzivatele` AS `u` ON `u`.`uzivatele_id` = `k2`.`uzivatel_id`
    WHERE `u`.`prezdivka` = 'Denny'
);

-- ANY – porovnání s ALESPOŇ JEDNOU hodnotou poddotazu
SELECT `c`.`titulek`
FROM `clanky` AS `c`
WHERE `c`.`publikovano` < ANY (
    SELECT `c2`.`publikovano`
    FROM `clanky` AS `c2`
    WHERE `c2`.`autor_id` = 2
);

-- CTE (Common Table Expression) – WITH – čitelnější alternativa k poddotazu
WITH faktury_srpen AS (
    SELECT `ii`.`item_id`, `it`.`title`, `it`.`price`
    FROM `item_invoice` AS `ii`
             JOIN `item` AS `it` ON `ii`.`item_id` = `it`.`product_id`
             JOIN `invoice` AS `i` ON `ii`.`invoice_id` = `i`.`invoice_id`
    WHERE `i`.`created` >= '2015-08-01'
      AND `i`.`created`  < '2015-09-01'
)
SELECT `item_id`, `title`, `price` FROM `faktury_srpen`
UNION ALL -- spojení tabulek pod sebe (musí mít stejný počet sloupců)
SELECT NULL, 'SOUČET', SUM(`price`) FROM `faktury_srpen`;


-- ============================================================
-- 15. ALTER TABLE – změna struktury tabulky
-- ============================================================

-- Přidání sloupce
ALTER TABLE `komentare`
    ADD COLUMN `palce` INT;

-- Změna datového typu sloupce
ALTER TABLE `komentare`
    MODIFY COLUMN `palce` BIGINT;

-- Smazání sloupce
ALTER TABLE `komentare`
    DROP COLUMN `palce`;

-- Nastavení výchozí hodnoty AUTO_INCREMENT
ALTER TABLE `uzivatele`
    AUTO_INCREMENT = 1000;

-- Přidání indexu na jeden sloupec
ALTER TABLE `clanky`
    ADD INDEX (`url`);

-- Přidání složeného indexu (více sloupců)
ALTER TABLE `uzivatele`
    ADD INDEX (`prezdivka`, `email`);

-- Změna ENGINE
ALTER TABLE `clanky` ENGINE = InnoDB;


-- ============================================================
-- 16. TRANSAKCE
-- ============================================================
/*
  Transakce zajišťuje ATOMIČNOST (buď se provede vše, nebo nic).
  Typické použití: převod peněz (odepsat + připsat).
*/

START TRANSACTION;
-- nebo: BEGIN;

UPDATE `ucty` SET `zustatek` = `zustatek` - 100 WHERE `cislo_uctu` = 123456789;
UPDATE `ucty` SET `zustatek` = `zustatek` + 100 WHERE `cislo_uctu` = 987654321;

COMMIT;     -- potvrzení – změny se zapíší

-- ROLLBACK; -- zrušení – změny se zahodí (použij místo COMMIT při chybě)


-- ============================================================
-- 17. POHLEDY (VIEW)
-- ============================================================
/*
  VIEW = uložený SELECT, který se chová jako virtuální tabulka.
  Při každém dotazu na VIEW se znovu provede podkladový SELECT.
*/

-- Vytvoření pohledu
CREATE VIEW `algoritmy` AS
SELECT *
FROM `clanky`
WHERE `clanky_id` IN (
    SELECT `clanek_id`
    FROM `clanek_sekce`
    WHERE `sekce_id` = (
        SELECT `sekce_id` FROM `sekce` WHERE `nazev` = 'Algoritmy'
    )
);

-- Použití pohledu jako normální tabulky
SELECT `titulek` FROM `algoritmy`;

-- Smazání pohledu
DROP VIEW `algoritmy`;


-- ============================================================
-- 18. INDEXY A OPTIMALIZACE
-- ============================================================
/*
  Index urychluje vyhledávání, ale zpomaluje INSERT/UPDATE/DELETE.
  Vyplatí se pro sloupce, podle kterých se ČASTO vyhledává nebo řadí.

  PRIMARY KEY je vždy indexovaný automaticky.
  UNIQUE vytváří unikátní index automaticky.
*/

-- Jednoduchý index
ALTER TABLE `clanky` ADD INDEX (`url`);

-- Fulltextový index (pro fulltextové vyhledávání)
ALTER TABLE `clanky` ADD FULLTEXT (`titulek`, `obsah`);
-- nebo při CREATE TABLE:
-- FULLTEXT (`titulek`, `obsah`)

-- Výpis indexů tabulky
SHOW INDEX FROM `clanky`;

-- Smazání indexu
ALTER TABLE `clanky` DROP INDEX `url`;


-- ============================================================
-- 19. FULLTEXTOVÉ VYHLEDÁVÁNÍ
-- ============================================================
/*
  Rychlejší a chytřejší než LIKE pro hledání v delších textech.
  Vyžaduje FULLTEXT index.
  ⚠️  Funguje pouze s enginem InnoDB nebo MyISAM.
  ⚠️  Krátká slova (< 4 znaky) jsou standardně ignorována.
*/

-- Základní vyhledávání (relevance automaticky)
SELECT `nazev`, `obsah`
FROM `prispevky`
WHERE MATCH(`nazev`, `obsah`) AGAINST('databáze');

-- IN BOOLEAN MODE – přesná kontrola; kratší slova fungují
--   +slovo  … musí obsahovat
--   -slovo  … nesmí obsahovat
--   *       … prefix (začíná na)
SELECT `id`, `nazev`, `obsah`
FROM `prispevky`
WHERE MATCH(`nazev`, `obsah`) AGAINST('+databáze -Oracle' IN BOOLEAN MODE);

SELECT `nazev` FROM `prispevky`
WHERE MATCH(`nazev`, `obsah`) AGAINST('data*' IN BOOLEAN MODE);


-- ============================================================
-- 20. TRIGGERY
-- ============================================================
/*
  Trigger = SQL kód, který se automaticky spustí
  BEFORE nebo AFTER události INSERT / UPDATE / DELETE na tabulce.

  Přístup k datům uvnitř triggeru:
    NEW.sloupec  – nová (vkládaná / aktualizovaná) hodnota
    OLD.sloupec  – původní (mazaná / měněná) hodnota

  Syntaxe:
    DELIMITER $
    CREATE TRIGGER nazev_triggeru {BEFORE|AFTER} {INSERT|UPDATE|DELETE}
    ON nazev_tabulky FOR EACH ROW
    BEGIN
        tělo;
    END$
    DELIMITER ;
*/

-- Příklad: BEFORE INSERT – aktualizace souhrnné statistiky před vložením
DELIMITER $
CREATE TRIGGER `before_insert_pobocky`
    BEFORE INSERT ON `pobocky`
    FOR EACH ROW
BEGIN
    UPDATE `statistika_pobocek`
    SET `pocet_pracovniku_celkem` = `pocet_pracovniku_celkem` + NEW.`pocet_pracovniku`;
END$
DELIMITER ;

-- Příklad: AFTER UPDATE – uložení záznamu do historie + podmínka IF
DELIMITER $
CREATE TRIGGER `before_update_pobocky`
    BEFORE UPDATE ON `pobocky`
    FOR EACH ROW
BEGIN
    IF NEW.`pocet_pracovniku` > OLD.`pocet_pracovniku` THEN
        INSERT INTO `historie_pobocek` VALUES (NULL, OLD.`id_pobocky`, OLD.`mesto`, OLD.`nazev`, OLD.`pocet_pracovniku`, NOW(), 'Update - zvětšena');
    ELSEIF NEW.`pocet_pracovniku` < OLD.`pocet_pracovniku` THEN
        INSERT INTO `historie_pobocek` VALUES (NULL, OLD.`id_pobocky`, OLD.`mesto`, OLD.`nazev`, OLD.`pocet_pracovniku`, NOW(), 'Update - zmenšena');
    ELSE
        INSERT INTO `historie_pobocek` VALUES (NULL, OLD.`id_pobocky`, OLD.`mesto`, OLD.`nazev`, OLD.`pocet_pracovniku`, NOW(), 'Update - nezměněna');
    END IF;

    UPDATE `statistika_pobocek`
    SET `pocet_pracovniku_celkem` = `pocet_pracovniku_celkem` - OLD.`pocet_pracovniku` + NEW.`pocet_pracovniku`;
END$
DELIMITER ;

-- Příklad: AFTER DELETE – logování smazaného záznamu
DELIMITER $
CREATE TRIGGER `after_delete_pobocky`
    AFTER DELETE ON `pobocky`
    FOR EACH ROW
BEGIN
    INSERT INTO `historie_pobocek`
    VALUES (NULL, OLD.`id_pobocky`, OLD.`mesto`, OLD.`nazev`, OLD.`pocet_pracovniku`, NOW(), 'DELETE');

    UPDATE `statistika_pobocek`
    SET `pocet_pracovniku_celkem` = `pocet_pracovniku_celkem` - OLD.`pocet_pracovniku`;
END$
DELIMITER ;

-- Výpis triggerů databáze
SHOW TRIGGERS FROM `it_web_magazine1`;

-- Smazání triggeru
DROP TRIGGER `before_update_pobocky`;
DROP TRIGGER IF EXISTS `before_update_pobocky`;


-- ============================================================
-- 21. ULOŽENÉ PROCEDURY A FUNKCE
-- ============================================================
/*
  Procedura = pojmenovaná sada příkazů uložená na serveru.
  Zavolá se příkazem CALL.

  Typy parametrů:
    IN    – vstupní (hodnota se předá do procedury)
    OUT   – výstupní (procedura ho naplní, volající si ho přečte)
    INOUT – obojí

  Funkce je podobná proceduře, ale VRACÍ jednu hodnotu (RETURNS)
  a lze ji použít přímo v SELECT, WHERE atd.
*/

-- ---- Procedura bez parametrů ----
DELIMITER $
CREATE PROCEDURE `GetPobocky`()
BEGIN
    SELECT * FROM `pobocky`;
END$
DELIMITER ;

CALL `GetPobocky`();
DROP PROCEDURE IF EXISTS `GetPobocky`;

-- ---- Procedura s IN parametrem ----
DELIMITER $
CREATE PROCEDURE `SetPobocky`(
    IN p_mesto           VARCHAR(50),
    IN p_nazev           VARCHAR(50),
    IN p_pocet_prac      INT
)
BEGIN
    INSERT INTO `pobocky` VALUES (NULL, p_mesto, p_nazev, p_pocet_prac);
END$
DELIMITER ;

CALL `SetPobocky`('Praha', 'Pobočka Praha', 120);

-- ---- Procedura s OUT parametrem ----
DELIMITER $
CREATE PROCEDURE `PocetPobocekVeMeste`(
    IN  p_mesto       VARCHAR(50),
    OUT p_pocet       INT
)
BEGIN
    SELECT COUNT(`id_pobocky`) INTO p_pocet
    FROM `pobocky`
    WHERE `mesto` LIKE p_mesto;
END$
DELIMITER ;

CALL `PocetPobocekVeMeste`('Praha', @pocet);
SELECT @pocet AS `Počet poboček`;

-- ---- Procedura s INOUT parametrem ----
DELIMITER $
CREATE PROCEDURE `Pocitadlo`(
    INOUT p_hodnota INT,
    IN    p_navyseni INT
)
BEGIN
    SET p_hodnota = p_hodnota + p_navyseni;
END$
DELIMITER ;

SET @hodnota = 0;
CALL `Pocitadlo`(@hodnota, 5);
CALL `Pocitadlo`(@hodnota, 3);
SELECT @hodnota;   -- výsledek: 8

-- ---- Funkce ----
DELIMITER $
CREATE FUNCTION `VelikostPobocky`(pocet_zam INT)
    RETURNS VARCHAR(60)
BEGIN
    DECLARE velikost VARCHAR(50);

    IF pocet_zam < 50 THEN
        SET velikost = 'Malá pobočka';
    ELSEIF pocet_zam < 100 THEN
        SET velikost = 'Střední pobočka';
    ELSE
        SET velikost = 'Velká pobočka';
    END IF;

    RETURN velikost;
END$
DELIMITER ;

-- Použití funkce v SELECT
SELECT *, `VelikostPobocky`(`pocet_pracovniku`) AS `Velikost`
FROM `pobocky`;

DROP FUNCTION IF EXISTS `VelikostPobocky`;

-- Výpis procedur / triggerů
SHOW PROCEDURE STATUS;
SHOW TRIGGERS;


-- ============================================================
-- 22. CIZÍ KLÍČE (FOREIGN KEY)
-- ============================================================
/*
  Cizí klíč propojuje sloupec v podřízené tabulce s primárním klíčem
  nadřízené tabulky a zajišťuje REFERENČNÍ INTEGRITU.

  ⚠️ Vyžaduje engine InnoDB.

  Chování ON DELETE / ON UPDATE:
    CASCADE   – kaskádově smaže/upraví všechny závislé záznamy
    SET NULL  – nastaví cizí klíč na NULL (sloupec musí povolovat NULL!)
    RESTRICT  – zabrání operaci, pokud existují závislé záznamy
    NO ACTION – jako RESTRICT (výchozí)
*/

-- Přidání cizího klíče přes ALTER TABLE
ALTER TABLE `komentare`
    ADD CONSTRAINT `fk_komentar_clanek`
        FOREIGN KEY (`clanek_id`)
            REFERENCES `clanky` (`clanky_id`)
            ON UPDATE CASCADE
            ON DELETE CASCADE;

-- Kombinace různých chování
ALTER TABLE `komentare`
    ADD CONSTRAINT `fk_komentar_uzivatel`
        FOREIGN KEY (`uzivatel_id`)
            REFERENCES `uzivatele` (`uzivatele_id`)
            ON UPDATE CASCADE
            ON DELETE SET NULL;   -- při smazání uživatele → NULL (ne smazání komentáře)

-- Při CREATE TABLE
CREATE TABLE `objednavky`
(
    `objednavka_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `uzivatel_id`   INT NOT NULL,
    CONSTRAINT `fk_obj_uzivatel`
        FOREIGN KEY (`uzivatel_id`) REFERENCES `uzivatele` (`uzivatele_id`)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);

-- Zjištění existujících cizích klíčů tabulky
SHOW CREATE TABLE `komentare`;

-- Smazání cizího klíče
ALTER TABLE `komentare`
    DROP FOREIGN KEY `fk_komentar_clanek`;

-- Zjištění cizích klíčů v databázi (information_schema)
SELECT `TABLE_NAME`, `CONSTRAINT_NAME`, `REFERENCED_TABLE_NAME`,
       `DELETE_RULE`, `UPDATE_RULE`
FROM `information_schema`.`REFERENTIAL_CONSTRAINTS`
WHERE `CONSTRAINT_SCHEMA` = 'moje_db';

-- Dočasné vypnutí kontrol cizích klíčů (používat opatrně!)
SET FOREIGN_KEY_CHECKS = 0;
-- ... operace ...
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- 23. UŽIVATELÉ A OPRÁVNĚNÍ
-- ============================================================

-- Vytvoření uživatele
CREATE USER IF NOT EXISTS `novak`@`localhost` IDENTIFIED BY 'silneHeslo123';

-- Udělení oprávnění
GRANT SELECT, INSERT, UPDATE ON `moje_db`.* TO `novak`@`localhost`;
GRANT ALL PRIVILEGES ON `moje_db`.* TO `novak`@`localhost`;

-- Přehled oprávnění:
/*
  ALL PRIVILEGES – vše (včetně EXECUTE)
  SELECT         – čtení dat
  INSERT         – vkládání dat
  UPDATE         – aktualizace dat
  DELETE         – mazání dat
  CREATE         – vytváření tabulek a databází
  DROP           – mazání tabulek a databází
  EXECUTE        – spouštění uložených procedur/funkcí
*/

-- Výpis uživatelů
SELECT `user`, `host` FROM `mysql`.`user`;

-- Smazání uživatele
DROP USER IF EXISTS `novak`@`localhost`;

-- DEFINER vs. INVOKER v procedurách/funkcích:
/*
  DEFINER (výchozí) – procedura běží s právy svého TVŮRCE (např. root)
                      → uživatel bez DELETE může smazat přes proceduru
  INVOKER           – procedura běží s právy VOLAJÍCÍHO uživatele
                      → uživatel bez DELETE dostane chybu
*/


-- ============================================================
-- RYCHLÝ PŘEHLED PŘÍKAZŮ – CHEAT SHEET
-- ============================================================
/*
  ┌─────────────────────────────────────────────────────────────┐
  │ DATABÁZE                                                    │
  │   CREATE DATABASE db CHARSET utf8 COLLATE utf8_czech_ci;    │
  │   DROP DATABASE db;                                         │
  │                                                             │
  │ TABULKY                                                     │
  │   CREATE TABLE t (...);  DROP TABLE t;                      │
  │   ALTER TABLE t ADD COLUMN c INT;                           │
  │   ALTER TABLE t MODIFY COLUMN c BIGINT;                     │
  │   ALTER TABLE t DROP COLUMN c;                              │
  │                                                             │
  │ DATA                                                        │
  │   INSERT INTO t (sl1,sl2) VALUES (v1,v2),(v3,v4);           │
  │   UPDATE t SET sl1=v1 WHERE podmínka;                       │
  │   DELETE FROM t WHERE podmínka;                             │
  │   TRUNCATE TABLE t;                                         │
  │                                                             │
  │ VÝBĚR                                                       │
  │   SELECT sl FROM t WHERE p ORDER BY sl LIMIT n;             │
  │   GROUP BY sl HAVING agregace > hodnota                     │
  │   JOIN t2 ON t.id = t2.fk                                   │
  │                                                             │
  │ POKROČILÉ                                                   │
  │   CREATE VIEW v AS SELECT ...;                              │
  │   CREATE TRIGGER tr AFTER INSERT ON t FOR EACH ROW BEGIN..  │
  │   CREATE PROCEDURE p(IN x INT) BEGIN ... END;               │
  │   CREATE FUNCTION f(x INT) RETURNS INT BEGIN ... END;       │
  │   ALTER TABLE t ADD CONSTRAINT fk FOREIGN KEY (col)         │
  │       REFERENCES t2(col) ON DELETE CASCADE;                 │
  │   GRANT SELECT ON db.* TO user@localhost;                   │
  └─────────────────────────────────────────────────────────────┘
*/
