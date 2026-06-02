# 🗄️ MySQL / MariaDB – Přehled řešených úloh

Komplexní sbírka SQL příkladů pokrývající manipulaci s daty, výběrové dotazy, spojování tabulek, poddotazy, uložené procedury a triggery. Příklady jsou rozděleny do tematických sekcí od základních po pokročilé.

---

## 📁 Struktura databází

Příklady pracují se třemi schématy:

| Schéma | Popis |
|---|---|
| `it_web_magazine1` | Webový magazín – uživatelé, články, komentáře |
| `insane_racing1` | Závodní simulátor – vozidla, turnaje, transakce, výhry |
| `simple_money1` | Jednoduchý finanční systém – adresy, uživatelé, produkty, bankovní účty |

---

## 📋 Obsah

1. [Manipulace s daty – základní](#1-manipulace-s-daty--základní)
2. [Manipulace s daty – pokročilá](#2-manipulace-s-daty--pokročilá)
3. [Manipulace s daty – bonus](#3-manipulace-s-daty--bonus)
4. [Výběr dat (SELECT)](#4-výběr-dat-select)
5. [Řazení, agregace a seskupování](#5-řazení-agregace-a-seskupování)
6. [Spojování tabulek (JOIN)](#6-spojování-tabulek-join)
7. [Poddotazy (Subqueries)](#7-poddotazy-subqueries)
8. [Uložené procedury (Procedures)](#8-uložené-procedury-procedures)
9. [Triggery](#9-triggery)

---

## 1. Manipulace s daty – základní

Základní příkazy `INSERT`, `UPDATE` a `DELETE` pro jednotlivé záznamy.

```sql
-- Odstranění uživatele podle emailu
DELETE FROM it_web_magazine1.uzivatele 
WHERE email = 'ema@centrum.cz';

-- Přidání měny Bitcoin s kurzem k USD
INSERT INTO insane_racing1.meny (nazev, zkratka, kurz_vuci_USD)
VALUES ('Bitcoin', 'BTC', '0.00008');

-- Aktualizace názvu obce v tabulce address
UPDATE simple_money1.address
SET city = 'Mikulow'
WHERE city = 'Mikulovice';
```

---

## 2. Manipulace s daty – pokročilá

Hromadné operace a podmíněné aktualizace více záznamů najednou.

```sql
-- Hromadné vložení více uživatelů jedním příkazem
INSERT INTO it_web_magazine1.uzivatele (prezdivka, email, heslo)
VALUES 
    ('Antonín Nevrlý', 'antonevrly@email.cz', '5ly_poas7#gf'),
    ('Marek Horák',    'iloveanime@gmail.com', '6SA4Ap_s32$f');

-- Omezení maximální rychlosti všech vozidel nad limit
UPDATE insane_racing1.vozidla
SET max_rychlost = 320
WHERE max_rychlost > 320;

-- Odstranění konkrétních adres podle ulice a čísla popisného
DELETE FROM simple_money1.address
WHERE street = 'Hladná' AND (house_number = 13 OR house_number = 28);
```

---

## 3. Manipulace s daty – bonus

Pokročilejší příklady kombinující podmínky a aritmetické výrazy.

```sql
-- Označení starých článků jako zastaralé
UPDATE it_web_magazine1.clanky
SET popis = 'Zastaralý'
WHERE publikovano <= '2005-01-01';

-- Odstranění vozidel s nízkým hodnocením
DELETE FROM insane_racing1.vozidla 
WHERE nazev = 'Moped' AND hodnoceni <= 30;

-- Zvýšení ceny produktu o fixní částku
UPDATE simple_money1.item
SET price = price + 100
WHERE product_id = 29;
```

---

## 4. Výběr dat (SELECT)

Filtrování záznamů pomocí `WHERE`, `LIKE`, `IN` a dalších operátorů.

```sql
-- Vyhledání uživatele podle přezdívky
SELECT * FROM it_web_magazine1.uzivatele WHERE prezdivka = 'Denny';

-- Vyhledání turnajů podle vzoru názvu
SELECT nazev, start FROM insane_racing1.turnaje 
WHERE nazev LIKE '%Grand%Prix%';

-- Filtrování pomocí IN
SELECT * FROM it_web_magazine1.uzivatele WHERE uzivatele_id IN (2, 3, 4);
SELECT nazev FROM insane_racing1.vozidla WHERE nazev IN ('Sáně', 'Moped', 'Pickup');

-- Vyhledávání podle délky a pozice znaků (wildcard maska)
SELECT name FROM simple_money1.user WHERE name LIKE '___o___';
```

> **Tip:** Maska `___o___` odpovídá přesně sedmiznakovým hodnotám, kde čtvrtý znak je `o`.

---

## 5. Řazení, agregace a seskupování

Použití `ORDER BY`, `GROUP BY`, `COUNT`, `AVG` a aliasů.

```sql
-- Seřazení uživatelů abecedně
SELECT prezdivka, email FROM it_web_magazine1.uzivatele ORDER BY prezdivka;

-- Výpočet průměrného zrychlení vozidel
SELECT AVG(zrychleni) AS prumerne_zrychleni FROM insane_racing1.vozidla;

-- Počet produktů obsahujících barvu v názvu
SELECT COUNT(*) AS pocet_zlutych_produktu 
FROM simple_money1.item
WHERE title LIKE '%žlutá%' OR title LIKE '%yellow%';

-- Počet komentářů na uživatele (seskupení)
SELECT uzivatel_id, COUNT(*) AS pocet_komentaru
FROM it_web_magazine1.komentare
GROUP BY uzivatel_id
ORDER BY uzivatel_id;
```

---

## 6. Spojování tabulek (JOIN)

Příklady `INNER JOIN` a `RIGHT JOIN` pro propojení více tabulek.

```sql
-- INNER JOIN: Komentáře s přezdívkami jejich autorů
SELECT k.obsah, u.prezdivka
FROM it_web_magazine1.komentare AS k
JOIN it_web_magazine1.uzivatele AS u ON k.uzivatel_id = u.uzivatele_id;

-- RIGHT JOIN: Všechna vozidla včetně těch bez výhry
SELECT v.vyhra_id, voz.nazev, v.poznamka
FROM insane_racing1.vyhry AS v
RIGHT JOIN insane_racing1.vozidla AS voz ON voz.vozidlo_id = v.vozidla_id;

-- JOIN s filtrováním: Články od roku 2010 s klíčovým slovem "hra"
SELECT c.publikovano, c.titulek, u.prezdivka
FROM it_web_magazine1.clanky AS c
JOIN it_web_magazine1.uzivatele AS u ON c.autor_id = u.uzivatele_id
WHERE c.publikovano >= '2010-01-01'
  AND c.klicova_slova LIKE '%hra%';
```

---

## 7. Poddotazy (Subqueries)

Vnořené dotazy pro komplexní filtrování a kontrolu konzistence dat.

```sql
-- Výběr článků konkrétního autora pomocí poddotazu
SELECT c.titulek
FROM it_web_magazine1.clanky AS c
WHERE c.autor_id IN (
    SELECT u.uzivatele_id
    FROM it_web_magazine1.uzivatele AS u
    WHERE u.prezdivka = 'DENNY'
);

-- Kontrola konzistence: Bankovní účty s neexistujícím kódem banky
SELECT *
FROM simple_money1.bank_account AS ba
WHERE ba.bank_code NOT IN (
    SELECT bc.bank_code FROM simple_money1.bank_code AS bc
);

-- Komentáře vybraných uživatelů k prvním dvěma článkům
SELECT k.clanek_id, k.obsah AS KOMENTAR, u.prezdivka AS AUTOR
FROM it_web_magazine1.komentare AS k
JOIN it_web_magazine1.uzivatele AS u ON k.uzivatel_id = u.uzivatele_id
WHERE (u.prezdivka = 'david' OR u.prezdivka = 'EMA')
  AND k.clanek_id <= 2
ORDER BY k.clanek_id;
```

---

## 8. Uložené procedury (Procedures)

### Přehled procedur

| Procedura | Schéma | Popis | Parametry |
|---|---|---|---|
| `FindThief` | `it_web_magazine1` | Vyhledání autora článku podle klíčového slova v popisu | `IN hledane_slovo` |
| `SelectCar` | `insane_racing1` | Nejrychlejší vozidlo do 3 000 kg | – |
| `ToJeBordel` | `simple_money1` | Nejlevnější produkt podle přibližného názvu | `IN priblizny_nazev_produktu` |
| `Zlodej` | `it_web_magazine1` | Kompletní info o uživateli a jeho článku se slovem "mouse" | `IN jmeno` |
| `BohatyAVykutaleny` | `insane_racing1` | Součet přijatých transakcí uživatele | `IN id_uzivatele`, `INOUT jiz_spoctena_suma` |
| `VrabecVHrsti` | `simple_money1` | Detail adresy uživatele do OUT proměnných | `IN id_uzivatele`, `OUT adresa_cislo, ulice, ...` |
| `ZmetourJeden` | `it_web_magazine1` | Podmíněné vyhodnocení přezdívky uživatele | `IN p_id_uzivatele`, `OUT jaky_je` |
| `JsiNahranyChlapce` | `insane_racing1` | Vynulování transakcí a vrácení nového součtu | `IN id_uzivatele`, `OUT prasulky` |
| `vyberProdukt` | `simple_money1` | Nejdražší produkt v cenovém rozmezí | `IN hledany_produkt, cena_min, cena_max`, `OUT produkt, cena` |

---

### Ukázky kódu procedur

#### `FindThief` – IN parametr
```sql
DELIMITER $
CREATE PROCEDURE it_web_magazine1.FindThief(IN hledane_slovo VARCHAR(10))
BEGIN
    SELECT u.prezdivka
    FROM it_web_magazine1.clanky AS c
    JOIN it_web_magazine1.uzivatele AS u ON c.autor_id = u.uzivatele_id
    WHERE c.popis LIKE CONCAT('%', hledane_slovo, '%');
END $
DELIMITER ;
```

#### `BohatyAVykutaleny` – INOUT parametr
```sql
DELIMITER $
CREATE PROCEDURE insane_racing1.BohatyAVykutaleny(
    IN id_uzivatele INT,
    INOUT jiz_spoctena_suma INT
)
BEGIN
    SET jiz_spoctena_suma = (
        SELECT SUM(castka)
        FROM insane_racing1.transakce
        WHERE uzivatel_id = id_uzivatele AND stav = 'obdrzeno'
    );
END $
DELIMITER ;
```

#### `VrabecVHrsti` – OUT parametry
```sql
DELIMITER $
CREATE PROCEDURE simple_money1.VrabecVHrsti(
    IN  id_uzivatele INT,
    OUT adresa_cislo INT,
    OUT ulice        VARCHAR(60),
    OUT registrace_cislo INT,
    OUT dum_cislo    INT,
    OUT mesto        VARCHAR(60),
    OUT psc          INT
)
BEGIN
    SELECT a.address_id, a.street, a.registry_number, a.house_number, a.city, a.zip
    INTO adresa_cislo, ulice, registrace_cislo, dum_cislo, mesto, psc
    FROM simple_money1.person AS p
    JOIN simple_money1.address AS a ON p.address_id = a.address_id
    WHERE p.person_id = id_uzivatele;
END $
DELIMITER ;
```

#### `ZmetourJeden` – IF-ELSE větvení
```sql
DELIMITER $
CREATE PROCEDURE it_web_magazine1.ZmetourJeden(
    IN  p_id_uzivatele INT,
    OUT jaky_je        VARCHAR(30)
)
BEGIN
    DECLARE v_nik VARCHAR(60);
    SELECT prezdivka INTO v_nik
    FROM it_web_magazine1.uzivatele
    WHERE uzivatele_id = p_id_uzivatele;

    IF v_nik = 'denny' THEN
        SET jaky_je = 'ZMETEK';
    ELSE
        SET jaky_je = 'NEVINNÝ ČLOVÍČEK';
    END IF;
END $
DELIMITER ;
```

#### `vyberProdukt` – kombinace IN a OUT parametrů
```sql
DELIMITER $
CREATE PROCEDURE simple_money1.vyberProdukt(
    IN  hledany_produkt VARCHAR(60),
    IN  cena_min        INT,
    IN  cena_max        INT,
    OUT produkt         VARCHAR(160),
    OUT cena            INT
)
BEGIN
    SELECT title, price INTO produkt, cena
    FROM simple_money1.item
    WHERE title LIKE CONCAT('%', hledany_produkt, '%')
      AND price BETWEEN cena_min AND cena_max
    ORDER BY price DESC
    LIMIT 1;
END $
DELIMITER ;
```

---

## 9. Triggery

Triggery se automaticky spouštějí při události `INSERT`, `UPDATE` nebo `DELETE` na dané tabulce. Používají se pro auditování změn, kaskádové mazání nebo automatické aktualizace dat.

### Přehled triggerů

| Trigger | Schéma | Událost | Tabulka | Popis |
|---|---|---|---|---|
| `after_update` | `it_web_magazine1` | AFTER UPDATE | `komentare` | Uloží původní obsah komentáře do `historie_zmen` |
| `after_delete_uzivatel` | `insane_racing1` | AFTER DELETE | `uzivatele` | Smaže záznamy uživatele z `uzivatele_turnaje` a `uzivatele_vozidla` |
| `insert_to_country` | `simple_money1` | AFTER INSERT | `country` | Aktualizuje `country_id` v tabulce `address` pro obec Černíny |
| `insert_clanek_pochleb` | `it_web_magazine1` | AFTER INSERT | `clanky` | Vloží dva pochlebné komentáře ke každému novému článku autora s ID 2 |
| `update_meny_dolar` | `insane_racing1` | AFTER INSERT | `vyhry` | Nastaví kurz všech měn obsahujících "Dollar" (kromě American Dollar) na 40 |
| `update_item_top_10` | `simple_money1` | AFTER INSERT | `user` | Přidá "BLACK FRIDAY SALE!!!" k názvům 10 nejdražších produktů a sníží cenu o 10 % |
| `aktivovano_300` | `insane_racing1` | AFTER INSERT | `transakce` | Aktivuje uživatele, pokud jeho celková suma transakcí překročí 300 |
| `plati_ZUNO` | `simple_money1` | AFTER UPDATE | `bank_code` | Při přejmenování banky na výroční název nastaví cenu každého 25. produktu na 0 |

---

### Ukázky kódu triggerů

#### `after_update` – audit změn komentářů (AFTER UPDATE)

Po úpravě komentáře se původní znění automaticky zaznamená do archivní tabulky.

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS after_update AFTER UPDATE
ON it_web_magazine1.komentare FOR EACH ROW
BEGIN
    INSERT INTO it_web_magazine1.historie_zmen
        (id, komentare_id, clanek_id, uzivatel_id, obsah, datum)
    VALUES
        (NULL, OLD.komentare_id, OLD.clanek_id, OLD.uzivatel_id, OLD.obsah, NOW());
END $
DELIMITER ;

-- Test triggeru:
UPDATE it_web_magazine1.komentare
SET obsah = 'ROZUMÍM TOMU!'
WHERE komentare_id = 7;
```

> **Klíčové:** `OLD.sloupec` obsahuje hodnoty **před** změnou, `NEW.sloupec` hodnoty **po** změně.

---

#### `after_delete_uzivatel` – kaskádové mazání (AFTER DELETE)

Při smazání uživatele se automaticky odstraní i jeho záznamy v propojených tabulkách.

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS after_delete_uzivatel AFTER DELETE
ON insane_racing1.uzivatele FOR EACH ROW
BEGIN
    DELETE FROM insane_racing1.uzivatele_turnaje WHERE uzivatel_id = OLD.uzivatel_id;
    DELETE FROM insane_racing1.uzivatele_vozidla WHERE uzivatel_id = OLD.uzivatel_id;
END $
DELIMITER ;

-- Test triggeru:
DELETE FROM insane_racing1.uzivatele WHERE uzivatel_id = 11;
```

---

#### `insert_to_country` – podmíněná aktualizace (AFTER INSERT + IF)

Trigger se spustí po každém vložení do tabulky, ale akci provede jen při splnění podmínky.

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS insert_to_country AFTER INSERT
ON simple_money1.country FOR EACH ROW
BEGIN
    IF NEW.title = 'JAR' THEN
        UPDATE simple_money1.address
        SET country_id = NEW.country_id
        WHERE city = 'Černiny';
    END IF;
END $
DELIMITER ;

-- Test triggeru:
INSERT INTO simple_money1.country VALUES (NULL, 'JAR');
```

---

#### `insert_clanek_pochleb` – vložení více záznamů podmíněně (AFTER INSERT)

Trigger vkládá komentáře pouze pokud článek napsal konkrétní autor (ID 2).

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS insert_clanek_pochleb AFTER INSERT
ON it_web_magazine1.clanky FOR EACH ROW
BEGIN
    IF NEW.autor_id = 2 THEN
        INSERT INTO it_web_magazine1.komentare VALUES
            (NULL, NEW.clanky_id, 1, 'Boží článek!', NOW()),
            (NULL, NEW.clanky_id, 3, 'Kdyby jsi kandidoval na prezidenta, hned tě volím.', NOW());
    END IF;
END $
DELIMITER ;
```

---

#### `aktivovano_300` – výpočet agregace uvnitř triggeru (AFTER INSERT)

Trigger po každé nové transakci přepočítá součet a podmíněně aktivuje uživatele.

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS aktivovano_300 AFTER INSERT
ON insane_racing1.transakce FOR EACH ROW
BEGIN
    UPDATE insane_racing1.uzivatele
    SET aktivovano = (
        IFNULL((SELECT SUM(castka)
                FROM insane_racing1.transakce
                WHERE uzivatel_id = NEW.uzivatel_id), 0)
    ) >= 300
    WHERE uzivatel_id = NEW.uzivatel_id;
END $
DELIMITER ;

-- Test triggeru:
INSERT INTO insane_racing1.transakce VALUES (NULL, 6, 80, 9, 80, NOW(), 'obdrzeno');
```

---

#### `update_item_top_10` – hromadná UPDATE uvnitř triggeru (AFTER INSERT)

Při registraci nového uživatele se spustí marketingová akce na 10 nejdražších produktů.

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS update_item_top_10 AFTER INSERT
ON simple_money1.user FOR EACH ROW
BEGIN
    UPDATE simple_money1.item AS i
    SET i.title = CONCAT(i.title, ' BLACK FRIDAY SALE!!!'),
        i.price = i.price * 0.9
    WHERE TRUE
    ORDER BY i.price DESC, i.product_id
    LIMIT 10;
END $
DELIMITER ;
```

---

#### `plati_ZUNO` – trigger na UPDATE tabulky (AFTER UPDATE)

Trigger reaguje na přejmenování záznamu a provede hromadnou aktualizaci produktů.

```sql
DELIMITER $
CREATE TRIGGER IF NOT EXISTS plati_ZUNO AFTER UPDATE
ON simple_money1.bank_code FOR EACH ROW
BEGIN
    IF NEW.bank_name = 'ZUNO BANK AG - 25 anniversary' THEN
        UPDATE simple_money1.item AS i
        SET i.title = CONCAT(i.title, ' zaplaceno ZUNO BANK AG'),
            i.price = 0
        WHERE i.product_id % 25 = 0;
    END IF;
END $
DELIMITER ;

-- Test triggeru:
UPDATE simple_money1.bank_code
SET bank_name = 'ZUNO BANK AG - 25 anniversary'
WHERE bank_name LIKE '%ZUNO BANK%';
```

---

### Správa triggerů

```sql
-- Zobrazení všech triggerů v databázi
SHOW TRIGGERS FROM it_web_magazine1;

-- Smazání triggeru
DROP TRIGGER it_web_magazine1.nazev_triggeru;
```

---

## 📌 Poznámky

- Všechny procedury a triggery jsou definovány s `DELIMITER $` aby nedocházelo ke konfliktu se středníky uvnitř těla.
- Při volání procedur s `OUT`/`INOUT` parametry je nutné předat uživatelské proměnné: `CALL procedura(1, @vysledek); SELECT @vysledek;`
- Triggery nelze volat ručně – spouštějí se automaticky při příslušné DML operaci.
- Příklady jsou kompatibilní s **MySQL 5.7+** a **MariaDB 10.3+**.

---

*Sbírka průběžně rozšiřována o nové příklady a techniky.*