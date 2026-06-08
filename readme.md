# 📊 MySQL Tahák & Učební pomůcka

Komplexní přehled syntaxe, datových typů, operací a pokročilých funkcí v MySQL. Tento dokument slouží jako rychlá referenční příručka (Cheat Sheet) pro každodenní práci s databázemi.

## 📌 Obsah

1. [Databáze – vytvoření, smazání](#1-databáze)
2. [Tabulky – vytvoření, smazání, přehled datových typů](#2-tabulky)
3. [Modifikátory sloupců (NOT NULL, AUTO_INCREMENT…)](#3-modifikátory-sloupců)
4. [INSERT – vkládání dat](#4-insert-–-vkládání-dat)
5. [UPDATE – aktualizace dat](#5-update-–-aktualizace-dat)
6. [DELETE / TRUNCATE – mazání dat](#6-delete-a-truncate-–-mazání-dat)
7. [SELECT – výběr dat, podmínky WHERE](#7-select-–-výběr-dat-a-podmínky-where)
8. [Operátory LIKE, BETWEEN, IN](#8-like-between-in)
9. [ORDER BY, LIMIT](#9-order-by-a-limit)
10. [Agregační funkce (COUNT, SUM, AVG, MIN, MAX)](#10-agregační-funkce)
11. [GROUP BY + HAVING](#11-group-by--having)
12. [JOIN (INNER, LEFT, RIGHT)](#12-join-–-dotazy-přes-více-tabulek)
13. [Aliasy tabulek a sloupců](#13-aliasy)
14. [Poddotazy (subqueries)](#14-poddotazy-subqueries)
15. [ALTER TABLE – změna struktury](#15-alter-table-–-změna-struktury-tabulky)
16. [Transakce (START TRANSACTION, COMMIT, ROLLBACK)](#16-transakce)
17. [Pohledy (VIEW)](#17-pohledy-view)
18. [Indexy a optimalizace](#18-indexy-a-optimalizace)
19. [Fulltext vyhledávání](#19-fulltextové-vyhledávání)
20. [Triggery](#20-triggery)
21. [Uložené procedury a funkce](#21-uložené-procedury-a-funkce)
22. [Cizí klíče (FOREIGN KEY)](#22-cizí-klíče-foreign-key)
23. [Uživatelé a oprávnění](#23-uživatelé-a-oprávnění)
24. [Rychlý přehled příkazů (Cheat Sheet)](#-rychlý-přehled-příkazů-–-cheat-sheet)

---

## 1. Databáze [Obsah](Obsah)

```sql
-- Vytvoření databáze (utf8 + české řazení)
CREATE DATABASE `moje_db` CHARACTER SET utf8 COLLATE utf8_czech_ci;

-- Smazání databáze
DROP DATABASE `moje_db`;
```

---

## 2. Tabulky

```sql
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
```

### 📋 Přehled datových typů

| Kategorie | Typ | Rozsah / Popis |
| :--- | :--- | :--- |
| **ČÍSLA** | `TINYINT` | -128 … 127 (nebo 0 … 255 `UNSIGNED`) |
| | `SMALLINT` | -32 768 … 32 767 |
| | `MEDIUMINT` | Střední celá čísla |
| | `INT` | -2 147 483 648 … 2 147 483 647 |
| | `BIGINT` | Velká celá čísla |
| | `FLOAT` / `DOUBLE` / `DECIMAL(m,d)` | Desetinná čísla |
| **TEXT** | `CHAR(n)` | Pevná délka, max. 255 znaků |
| | `VARCHAR(n)` | Proměnná délka, max. 65 535 B |
| | `TINYTEXT` | Max. 255 B |
| | `TEXT` | Max. 64 KB |
| | `MEDIUMTEXT` | Max. 16 MB |
| | `LONGTEXT` | Max. 4 GB |
| **DATUM A ČAS** | `DATE` | `'RRRR-MM-DD'` |
| | `TIME` | `'HH:MM:SS'` |
| | `DATETIME` | `'RRRR-MM-DD HH:MM:SS'` |
| | `TIMESTAMP` | Jako DATETIME, ale do roku 2038 – *raději nepoužívat* |
| **OSTATNÍ** | `BLOB` | Binární data (obrázky apod.) |
| | `BOOLEAN` | Alias pro `TINYINT(1)`; 0 = FALSE, 1 = TRUE |

---

## 3. Modifikátory sloupců

* **`NOT NULL`** – hodnota nesmí být NULL.
* **`NULL`** – hodnota může být NULL (výchozí chování).
* **`DEFAULT hodnota`** – výchozí hodnota při vložení bez uvedení sloupce.
* **`AUTO_INCREMENT`** – automaticky zvyšující se číslo (pouze pro `INT`/`BIGINT`).
* **`UNIQUE`** – hodnoty musí být v celém sloupci unikátní.
* **`PRIMARY KEY`** – primární klíč (automaticky definuje `UNIQUE` + `NOT NULL`).

---

## 4. INSERT – vkládání dat

```sql
-- Vložení jednoho záznamu
INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `datum_narozeni`, `pocet_clanku`)
VALUE ('Jan', 'Novák', '1984-11-03', 17);

-- Vložení více záznamů najonou (výkonnější než opakovaný INSERT)
INSERT INTO `uzivatele` (`jmeno`, `prijmeni`, `datum_narozeni`, `pocet_clanku`)
VALUES ('Tomáš', 'Marný',     '1989-02-01', 6),
       ('Josef', 'Nový',      '1972-12-20', 9),
       ('Michaela', 'Slavíková', '1990-08-14', 1);
```

---

## 5. UPDATE – aktualizace dat

> ⚠️ **POZOR:** VŽDY uváděj podmínku **`WHERE`**, jinak se změní **VŠECHNY** řádky v tabulce!

```sql
-- Aktualizace konkrétního záznamu
UPDATE `uzivatele`
SET `prijmeni`     = 'Dolejší',
    `pocet_clanku` = `pocet_clanku` + 1   -- aritmetika v SET je v pořádku
WHERE `uzivatele_id` = 4;

-- Aktualizace více řádků najednou (podmínka vrátí více záznamů)
UPDATE `vozidla`
SET `max_rychlost` = 320
WHERE `max_rychlost` > 320;
```

---

## 6. DELETE a TRUNCATE – mazání dat

```sql
-- Smazání konkrétního záznamu
DELETE FROM `uzivatele`
WHERE `uzivatele_id` = 2;

-- Smazání více záznamů podle podmínky
DELETE FROM `uzivatele`
WHERE (`jmeno` = 'Jan' AND `datum_narozeni` >= '1980-01-01')
   OR (`pocet_clanku` < 3);

-- TRUNCATE: smaže VŠECHNA data a resetuje AUTO_INCREMENT
-- (Rychlejší než DELETE bez WHERE, ale nelze vrátit transakcí!)
TRUNCATE TABLE `uzivatele`;
```

---

## 7. SELECT – výběr dat a podmínky WHERE

```sql
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

-- NULL hodnoty (vždy porovnávat pomocí IS / IS NOT)
SELECT * FROM `uzivatele` WHERE `pocet_clanku` IS NULL;
SELECT * FROM `uzivatele` WHERE `pocet_clanku` IS NOT NULL;
```

---

## 8. LIKE, BETWEEN, IN

```sql
-- LIKE – vzorové hledání (% = libovolný počet znaků, _ = přesně jeden znak)
SELECT * FROM `uzivatele` WHERE `prijmeni` LIKE 's%';       -- začíná na S
SELECT * FROM `uzivatele` WHERE `prijmeni` LIKE '_o___';    -- 5 znaků, 2. písmeno o
SELECT * FROM `uzivatele` WHERE `prijmeni` LIKE '%ová%';    -- obsahuje "ová"

-- BETWEEN – rozsah (včetně krajních hodnot)
SELECT * FROM `uzivatele`
WHERE `datum_narozeni` BETWEEN '1980-01-01' AND '1989-12-31';

-- IN – výčet hodnot (efektivní alternativa k několika OR)
SELECT * FROM `uzivatele`
WHERE `uzivatele_id` IN (2, 3, 4);

SELECT * FROM `vozidla`
WHERE `nazev` IN ('Sáně', 'Moped', 'Pickup');

-- NOT IN – vše MIMO definovaný výčet
SELECT * FROM `bank_account`
WHERE `bank_code` NOT IN (SELECT `bank_code` FROM `bank_code`);
```

---

## 9. ORDER BY a LIMIT

```sql
-- Řazení vzestupně (ASC = výchozí, netřeba uvádět)
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

-- LIMIT s OFFSET (přeskočí prvních N záznamů – ideální pro stránkování)
SELECT * FROM `uzivatele`
LIMIT 10 OFFSET 20;   -- vrátí záznamy 21–30
```

---

## 10. Agregační funkce

```sql
-- COUNT – počet řádků splňujících podmínku
SELECT COUNT(*) FROM `uzivatele` WHERE `pocet_clanku` > 0;

-- SUM – součet hodnot
SELECT SUM(`pocet_clanku`) FROM `uzivatele`
WHERE `datum_narozeni` > '1980-01-01';

-- AVG – průměrná hodnota
SELECT AVG(`pocet_clanku`) FROM `uzivatele`;

-- MIN / MAX – minimální a maximální hodnota
SELECT MIN(`datum_narozeni`) FROM `uzivatele`;
SELECT MAX(`pocet_clanku`)   FROM `uzivatele`;
```

> ⚠️ **POZOR:** Výběr `MIN`/`MAX` společně s dalšími nesouvisejícími sloupci (např. jméno) bez seskupení nevrátí správný řádek!
>
> ❌ **Špatně:** `SELECT jmeno, MIN(datum_narozeni) FROM uzivatele;`  
> ✔️ **Správně (pomocí ORDER BY + LIMIT 1):**
> ```sql
> SELECT `jmeno`, `prijmeni`, `datum_narozeni` FROM `uzivatele`
> ORDER BY `datum_narozeni`
> LIMIT 1;
> ```

---

## 11. GROUP BY + HAVING

### ⏳ Pořadí klauzulí v SQL dotazu:
`SELECT` … `FROM` … `WHERE` … `GROUP BY` … `HAVING` … `ORDER BY` … `LIMIT` …

* **`WHERE`** filtruje řádky **PŘED** seskupením.
* **`HAVING`** filtruje skupiny **PO** seskupení (používá se pro agregační výsledky).

```sql
-- GROUP BY – seskupení řádků
SELECT `jmeno`, COUNT(*) AS `pocet`
FROM `uzivatele`
GROUP BY `jmeno`
ORDER BY `jmeno`;

-- HAVING – filtrování skupin
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
HAVING `pocet_zakazniku` > 1;       -- filtruje PO seskupením
```

---

## 12. JOIN – dotazy přes více tabulek

**Schéma příkladu:** `clanky.autor_id` ↔ `uzivatele.uzivatele_id`

```sql
-- INNER JOIN – průnik (pouze záznamy, které mají shodu v obou tabulkách)
SELECT `c`.`titulek`, `u`.`prezdivka`
FROM `clanky` AS `c`
    INNER JOIN `uzivatele` AS `u` ON `c`.`autor_id` = `u`.`uzivatele_id`
ORDER BY `u`.`prezdivka`;

-- LEFT JOIN – všechny záznamy z LEVÉ tabulky + odpovídající z pravé (chybějící = NULL)
SELECT `c`.`titulek`, `u`.`prezdivka`
FROM `clanky` AS `c`
    LEFT JOIN `uzivatele` AS `u` ON `c`.`autor_id` = `u`.`uzivatele_id`;
-- -> zobrazí i články bez existujícího autora (prezdivka bude NULL)

-- RIGHT JOIN – všechny záznamy z PRAVÉ tabulky + odpovídající z levé (chybějící = NULL)
SELECT `c`.`titulek`, `u`.`prezdivka`
FROM `clanky` AS `c`
    RIGHT JOIN `uzivatele` AS `u` ON `c`.`autor_id` = `u`.`uzivatele_id`;
-- -> zobrazí i uživatele, kteří nenapsali žádný článek (titulek bude NULL)
```

> ⚠️ **POZOR:** Nikdy nepropojuj tabulky starým způsobem přes `WHERE` (tzv. "WHERE-ování"). Je to nečitelné a neefektivní!
>
> ❌ **Špatně:** `SELECT ... FROM clanky, uzivatele WHERE autor_id = uzivatele_id;`  
> ✔️ **Správně:** `SELECT ... FROM clanky JOIN uzivatele ON ...;`

```sql
-- JOIN přes 3 tabulky (komentáře + uživatelé + články)
SELECT `u`.`prezdivka`, `k`.`obsah`, `c`.`titulek`
FROM `komentare` AS `k`
    JOIN `uzivatele` AS `u` ON `u`.`uzivatele_id` = `k`.`uzivatel_id`
    JOIN `clanky`    AS `c` ON `c`.`clanky_id`    = `k`.`clanek_id`
ORDER BY `k`.`datum`;
```

---

## 13. Aliasy

```sql
-- Alias sloupce (klíčové slovo AS je nepovinné, ale doporučené pro čitelnost)
SELECT COUNT(*) AS `pocet_uzivatelu` FROM `uzivatele`;

-- Alias tabulky (výrazně zkracuje a zpřehledňuje zápis v JOIN dotech)
SELECT `u`.`prezdivka`, `c`.`titulek`
FROM `uzivatele` AS `u`
    JOIN `clanky` AS `c` ON `c`.`autor_id` = `u`.`uzivatele_id`;
```

---

## 14. Poddotazy (Subqueries)

```sql
-- Poddotaz ve WHERE – očekává a vrací právě jednu hodnotu
SELECT `c`.`titulek`
FROM `clanky` AS `c`
WHERE `c`.`autor_id` = (
    SELECT `u`.`uzivatele_id`
    FROM `uzivatele` AS `u`
    WHERE `u`.`prezdivka` = 'David'
    LIMIT 1
);

-- Poddotaz s IN – vrací více hodnot (množinu)
SELECT `c`.`titulek`
FROM `clanky` AS `c`
WHERE `c`.`autor_id` IN (
    SELECT `u`.`uzivatele_id`
    FROM `uzivatele` AS `u`
    WHERE `u`.`prezdivka` = 'David'
);

-- Korelovaný poddotaz v SELECT (spustí se pro každý řádek hlavního dotazu)
SELECT `u`.`prezdivka`,
       (SELECT COUNT(*)
        FROM `clanky` AS `c`
        WHERE `c`.`autor_id` = `u`.`uzivatele_id`) AS `pocet_clanku`
FROM `uzivatele` AS `u`
ORDER BY `pocet_clanku` DESC;

-- NOT EXISTS – vybere záznamy, pro které poddotaz nevrátí žádný výsledek
SELECT `u`.`prezdivka`
FROM `uzivatele` AS `u`
WHERE NOT EXISTS (
    SELECT * FROM `clanky` AS `c`
    WHERE `c`.`autor_id` = `u`.`uzivatele_id`
);

-- ALL – porovnání se VŠEMI hodnotami vrácenými poddotazem
SELECT `k`.`obsah`, `k`.`datum`
FROM `komentare` AS `k`
WHERE `k`.`datum` > ALL (
    SELECT `k2`.`datum`
    FROM `komentare` AS `k2`
        JOIN `uzivatele` AS `u` ON `u`.`uzivatele_id` = `k2`.`uzivatel_id`
    WHERE `u`.`prezdivka` = 'Denny'
);

-- ANY – porovnání s ALESPOŇ JEDNOU libovolnou hodnotou poddotazu
SELECT `c`.`titulek`
FROM `clanky` AS `c`
WHERE `c`.`publikovano` < ANY (
    SELECT `c2`.`publikovano`
    FROM `clanky` AS `c2`
    WHERE `c2`.`autor_id` = 2
);

-- CTE (Common Table Expression) / klauzule WITH – čitelnější alternativa ke složitým poddotazům
WITH faktury_srpen AS (
    SELECT `ii`.`item_id`, `it`.`title`, `it`.`price`
    FROM `item_invoice` AS `ii`
        JOIN `item` AS `it` ON `ii`.`item_id` = `it`.`product_id`
        JOIN `invoice` AS `i` ON `ii`.`invoice_id` = `i`.`invoice_id`
    WHERE `i`.`created` >= '2015-08-01'
      AND `i`.`created`  < '2015-09-01'
)
SELECT `item_id`, `title`, `price` FROM `faktury_srpen`
UNION ALL -- Vertikální spojení tabulek (musí mít identický počet a typ sloupců)
SELECT NULL, 'SOUČET', SUM(`price`) FROM `faktury_srpen`;
```

---

## 15. ALTER TABLE – změna struktury tabulky

```sql
-- Přidání nového sloupce
ALTER TABLE `komentare`
    ADD COLUMN `palce` INT;

-- Změna datového typu existujícího sloupce
ALTER TABLE `komentare`
    MODIFY COLUMN `palce` BIGINT;

-- Smazání sloupce
ALTER TABLE `komentare`
    DROP COLUMN `palce`;

-- Resetování / nastavení výchozí hodnoty AUTO_INCREMENT
ALTER TABLE `uzivatele`
    AUTO_INCREMENT = 1000;

-- Přidání indexu na jeden sloupec
ALTER TABLE `clanky`
    ADD INDEX (`url`);

-- Přidání složeného indexu (nad více sloupci)
ALTER TABLE `uzivatele`
    ADD INDEX (`prezdivka`, `email`);

-- Změna úložného systému (ENGINE)
ALTER TABLE `clanky` ENGINE = InnoDB;
```

---

## 16. Transakce

Transakce zajišťují vlastnost **ACID** (především atomičnost – buď se provede celá sada příkazů korektně, nebo se neprovede vůbec nic). Typickým příkladem je bankovní převod (odepsání z jednoho účtu a připsání na druhý).

```sql
START TRANSACTION;
-- Lze použít i: BEGIN;

    UPDATE `ucty` SET `zustatek` = `zustatek` - 100 WHERE `cislo_uctu` = 123456789;
    UPDATE `ucty` SET `zustatek` = `zustatek` + 100 WHERE `cislo_uctu` = 987654321;

COMMIT;     -- Potvrzení: změny se trvale zapíší do databáze

-- ROLLBACK; -- Zrušení: změny se zahodí a tabulky se vrátí do původního stavu před transakcí
```

---

## 17. Pohledy (VIEW)

`VIEW` funguje jako uložený `SELECT` dotaz, který se navenek chová jako virtuální tabulka. Při každém volání pohledu se na pozadí znovu vykoná definovaný podkladový dotaz.

```sql
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

-- Použití pohledu (stejné jako u běžné tabulky)
SELECT `titulek` FROM `algoritmy`;

-- Smazání pohledu
DROP VIEW `algoritmy`;
```

---

## 18. Indexy a optimalizace

Indexy výrazně urychlují vyhledávání (`SELECT`), ale zpomalují zápisové operace (`INSERT`, `UPDATE`, `DELETE`), protože se index musí při každé změně přepočítat. Vyplatí se je nasazovat na sloupce, podle kterých se často filtruje (`WHERE`) nebo řadí (`ORDER BY`).

* `PRIMARY KEY` automaticky vytváří unikátní index.
* Sloupec s modifikátorem `UNIQUE` rovněž generuje index automaticky.

```sql
-- Přidání jednoduchého indexu
ALTER TABLE `clanky` ADD INDEX (`url`);

-- Přidání fulltextového indexu
ALTER TABLE `clanky` ADD FULLTEXT (`titulek`, `obsah`);

-- Zobrazení všech indexů na tabulce
SHOW INDEX FROM `clanky`;

-- Smazání indexu
ALTER TABLE `clanky` DROP INDEX `url`;
```

---

## 19. Fulltextové vyhledávání

Je mnohem rychlejší a sofistikovanější než běžné vyhledávání pomocí `LIKE '%text%'`.
* ⚠️ Vyžaduje `FULLTEXT` index.
* ⚠️ Je podporováno pouze nad úložnými systémy **InnoDB** nebo **MyISAM**.
* ⚠️ Velmi krátká slova (standardně méně než 4 znaky) jsou indexem ignorována.

```sql
-- Základní vyhledávání (výsledky jsou automaticky seřazeny dle relevance)
SELECT `nazev`, `obsah`
FROM `prispevky`
WHERE MATCH(`nazev`, `obsah`) AGAINST('databáze');

-- IN BOOLEAN MODE – pokročilé vyhledávání s operátory (zde fungují i krátká slova)
--   +slovo -> musí obsahovat
--   -slovo -> nesmí obsahovat
--   * -> zástupný znak na konci (prefixové hledání)
SELECT `id`, `nazev`, `obsah`
FROM `prispevky`
WHERE MATCH(`nazev`, `obsah`) AGAINST('+databáze -Oracle' IN BOOLEAN MODE);

SELECT `nazev` FROM `prispevky`
WHERE MATCH(`nazev`, `obsah`) AGAINST('data*' IN BOOLEAN MODE);
```

---

## 20. Triggery

Trigger je pojmenovaný SQL blok, který se **automaticky spustí** před (`BEFORE`) nebo po (`AFTER`) provedení události `INSERT`, `UPDATE` nebo `DELETE` nad konkrétní tabulkou.

Uvnitř triggeru máme přístup ke speciálním proměnným:
* `NEW.sloupec` – obsahuje nově vkládanou / upravovanou hodnotu.
* `OLD.sloupec` – obsahuje původní (předchozí / mazanou) hodnotu.

```sql
-- Příklad: BEFORE INSERT – úprava souhrnné statistiky před fyzickým vložením
DELIMITER $
CREATE TRIGGER `before_insert_pobocky`
    BEFORE INSERT ON `pobocky`
    FOR EACH ROW
BEGIN
    UPDATE `statistika_pobocek`
    SET `pocet_pracovniku_celkem` = `pocet_pracovniku_celkem` + NEW.`pocet_pracovniku`;
END$
DELIMITER ;

-- Příklad: BEFORE UPDATE – zápis historie změn s využitím podmínky IF/ELSEIF
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

-- Příklad: AFTER DELETE – zalogování smazaného záznamu
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

-- Zobrazení triggerů v databázi
SHOW TRIGGERS FROM `it_web_magazine1`;

-- Odstranění triggeru
DROP TRIGGER IF EXISTS `before_update_pobocky`;
```

---

## 21. Uložené procedury a funkce

* **Procedura** je pojmenovaný blok příkazů uložený na serveru. Volá se explicitně pomocí příkazu `CALL`. Může mít parametry typu `IN` (vstupní), `OUT` (výstupní) a `INOUT` (vstupně-výstupní).
* **Funkce** je podobná proceduře, ale **vždy vrací právě jednu hodnotu** (`RETURNS`) a lze ji volat přímo uvnitř standardních SQL dotazů (např. v `SELECT` nebo `WHERE`).

```sql
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
SELECT @hodnota;   -- Výsledek bude 8

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

-- Použití vytvořené funkce přímo v SELECT dotazu
SELECT *, `VelikostPobocky`(`pocet_pracovniku`) AS `Velikost`
FROM `pobocky`;

DROP FUNCTION IF EXISTS `VelikostPobocky`;

-- Výpis všech dostupných procedur a funkcí
SHOW PROCEDURE STATUS;
SHOW FUNCTION STATUS;
```

---

## 22. Cizí klíče (FOREIGN KEY)

Propojuje sloupec v podřízené (závislé) tabulce s primárním klíčem nadřízené tabulky. Zajišťuje **referenční integritu** dat.
* ⚠️ Vyžaduje úložný systém **InnoDB**.

### Chování při smazání (`ON DELETE`) / úpravě (`ON UPDATE`):
* `CASCADE` – kaskádová reakce: smaže/upraví i všechny navázané záznamy v podřízené tabulce.
* `SET NULL` – nastaví hodnotu cizího klíče na `NULL` (sloupec v podřízené tabulce musí hodnotu `NULL` povolovat).
* `RESTRICT` / `NO ACTION` *(výchozí)* – zamezí operaci, dokud na záznam odkazují jakékoliv závislé řádky.

```sql
-- Přidání cizího klíče přes ALTER TABLE
ALTER TABLE `komentare`
    ADD CONSTRAINT `fk_komentar_clanek`
        FOREIGN KEY (`clanek_id`)
            REFERENCES `clanky` (`clanky_id`)
            ON UPDATE CASCADE
            ON DELETE CASCADE;

-- Kombinace různých typů chování
ALTER TABLE `komentare`
    ADD CONSTRAINT `fk_komentar_uzivatel`
        FOREIGN KEY (`uzivatel_id`)
            REFERENCES `uzivatele` (`uzivatele_id`)
            ON UPDATE CASCADE
            ON DELETE SET NULL;

-- Definice cizího klíče přímo při vytváření tabulky (CREATE TABLE)
CREATE TABLE `objednavky`
(
    `objednavka_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `uzivatel_id`   INT NOT NULL,
    CONSTRAINT `fk_obj_uzivatel`
        FOREIGN KEY (`uzivatel_id`) REFERENCES `uzivatele` (`uzivatele_id`)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Zobrazení kompletního SQL příkazu pro vytvoření tabulky (včetně cizích klíčů)
SHOW CREATE TABLE `komentare`;

-- Smazání cizího klíče
ALTER TABLE `komentare`
    DROP FOREIGN KEY `fk_komentar_clanek`;

-- Vyhledání cizích klíčů v systémové schémě
SELECT `TABLE_NAME`, `CONSTRAINT_NAME`, `REFERENCED_TABLE_NAME`, `DELETE_RULE`, `UPDATE_RULE`
FROM `information_schema`.`REFERENTIAL_CONSTRAINTS`
WHERE `CONSTRAINT_SCHEMA` = 'moje_db';

-- Dočasné vypnutí kontrol cizích klíčů (např. při importu velkých dat – používat opatrně!)
SET FOREIGN_KEY_CHECKS = 0;
-- ... vaše operace ...
SET FOREIGN_KEY_CHECKS = 1;
```

---

## 23. Uživatelé a oprávnění

```sql
-- Vytvoření nového uživatele (pokud neexistuje)
CREATE USER IF NOT EXISTS `novak`@`localhost` IDENTIFIED BY 'silneHeslo123';

-- Udělení konkrétních oprávnění nad konkrétní databází
GRANT SELECT, INSERT, UPDATE ON `moje_db`.* TO `novak`@`localhost`;

-- Udělení úplně všech oprávnění
GRANT ALL PRIVILEGES ON `moje_db`.* TO `novak`@`localhost`;

-- Výpis všech uživatelů registrovaných na MySQL serveru
SELECT `user`, `host` FROM `mysql`.`user`;

-- Smazání uživatele
DROP USER IF EXISTS `novak`@`localhost`;
```

### 🔐 Přehled základních oprávnění:
* `ALL PRIVILEGES` – udělí veškerá práva (včetně spouštění rutin).
* `SELECT` – právo na čtení a výběr dat.
* `INSERT` – právo na vkládání nových záznamů.
* `UPDATE` – právo na modifikaci stávajících dat.
* `DELETE` – právo na odstraňování řádků.
* `CREATE` – právo na zakládání nových tabulek nebo databází.
* `DROP` – právo na odstraňování celých tabulek či databází.
* `EXECUTE` – právo na spouštění uložených procedur a funkcí.

### 👥 Rozdíl mezi DEFINER a INVOKER v rutinách:
* **`DEFINER`** *(výchozí)* – Procedura se vykonává pod právy uživatele, který ji **vytvořil** (např. root). Uživatel, který nemá právo `DELETE`, tak může nepřímo smazat řádek, pokud k tomu použije tuto proceduru.
* **`INVOKER`** – Procedura se vykonává výhradně pod právy uživatele, který ji aktuálně **volá**. Pokud volající uživatel nemá potřebná práva, databáze vrátí chybu.

---

## ⚡ Rychlý přehled příkazů – Cheat Sheet

```sql
# DATABÁZE
  CREATE DATABASE db CHARSET utf8 COLLATE utf8_czech_ci;
  DROP DATABASE db;

# TABULKY
  CREATE TABLE t (...);  DROP TABLE t;
  ALTER TABLE t ADD COLUMN c INT;
  ALTER TABLE t MODIFY COLUMN c BIGINT;
  ALTER TABLE t DROP COLUMN c;

# DATA
  INSERT INTO t (sl1,sl2) VALUES (v1,v2),(v3,v4);
  UPDATE t SET sl1=v1 WHERE podmínka;
  DELETE FROM t WHERE podmínka;
  TRUNCATE TABLE t;

# VÝBĚR
  SELECT sl FROM t WHERE p ORDER BY sl LIMIT n;
  GROUP BY sl HAVING agregace > hodnota
  JOIN t2 ON t.id = t2.fk

# POKROČILÉ
  CREATE VIEW v AS SELECT ...;
  CREATE TRIGGER tr AFTER INSERT ON t FOR EACH ROW BEGIN..
  CREATE PROCEDURE p(IN x INT) BEGIN ... END;
  CREATE FUNCTION f(x INT) RETURNS INT BEGIN ... END;
  ALTER TABLE t ADD CONSTRAINT fk FOREIGN KEY (col) REFERENCES t2(col) ON DELETE CASCADE;
  GRANT SELECT ON db.* TO user@localhost;
```
