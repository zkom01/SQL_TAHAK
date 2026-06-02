-- ==================================================================================
-- ŘEŠENÉ ÚLOHY MYSQL/MARIADB - KOMPLETNÍ PŘEHLED (INSERT, UPDATE, DELETE, SELECT)
-- ==================================================================================

-- ----------------------------------------------------------------------------------
-- 1. JEDNODUCHÉ PŘÍKLADY (MANIPULACE S DATY)
-- ----------------------------------------------------------------------------------

-- Odstranění uživatele podle emailu
DELETE FROM it_web_magazine1.uzivatele 
WHERE email = 'ema@centrum.cz';

-- Přidání měny Bitcoin (zkratka BTC) s kurzem k USD
INSERT INTO insane_racing1.meny (nazev, zkratka, kurz_vuci_USD)
VALUES ('Bitcoin', 'BTC', '0.00008');

-- Aktualizace názvu obce v tabulce address
UPDATE simple_money1.address
SET city = 'Mikulow'
WHERE city = 'Mikulovice';


-- ----------------------------------------------------------------------------------
-- 2. POKROČILÉ PŘÍKLADY
-- ----------------------------------------------------------------------------------

-- Hromadné vložení uživatelů
INSERT INTO it_web_magazine1.uzivatele (prezdivka, email, heslo)
VALUES 
    ('Antonín Nevrlý', 'antonevrly@email.cz', '5ly_poas7#gf'),
    ('Marek Horák', 'iloveanime@gmail.com', '6SA4Ap_s32$f');

-- Omezení maximální rychlosti vozidel
UPDATE insane_racing1.vozidla
SET max_rychlost = 320
WHERE max_rychlost > 320;

-- Odstranění specifických adres podle ulice a čísla popisného
DELETE FROM simple_money1.address
WHERE street = 'Hladná' AND (house_number = 13 OR house_number = 28);


-- ----------------------------------------------------------------------------------
-- 3. BONUS - PŘÍKLADY PRO NÁROČNÉ
-- ----------------------------------------------------------------------------------

-- Označení starších článků jako zastaralé
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


-- ----------------------------------------------------------------------------------
-- 4. VÝBĚR DAT (SELECT)
-- ----------------------------------------------------------------------------------

-- Vyhledání uživatele podle přezdívky
SELECT * FROM it_web_magazine1.uzivatele WHERE prezdivka = 'Denny';

-- Vyhledání turnajů podle vzoru názvu
SELECT nazev, start FROM insane_racing1.turnaje 
WHERE nazev LIKE '%Grand%Prix%';

-- Filtrování s využitím IN a BETWEEN
SELECT * FROM it_web_magazine1.uzivatele WHERE uzivatele_id IN (2, 3, 4);
SELECT nazev FROM insane_racing1.vozidla WHERE nazev IN ('Sáně', 'Moped', 'Pickup');

-- Vyhledávání podle délky a pozice znaků (LIKE masky)
SELECT name FROM simple_money1.user WHERE name LIKE '___o___';


-- ----------------------------------------------------------------------------------
-- 5. ŘAZENÍ, AGREGACE A SESKUPOVÁNÍ
-- ----------------------------------------------------------------------------------

-- Seřazení uživatelů podle abecedy
SELECT prezdivka, email FROM it_web_magazine1.uzivatele ORDER BY prezdivka;

-- Výpočet průměrné hodnoty
SELECT AVG(zrychleni) AS prumerne_zrychleni FROM insane_racing1.vozidla;

-- Počet záznamů splňujících podmínku (včetně aliasu)
SELECT COUNT(*) AS pocet_zlutych_produktu 
FROM simple_money1.item
WHERE title LIKE '%žlutá%' OR title LIKE '%yellow%';

-- Seskupení dat a výpočet počtu výskytů
SELECT uzivatel_id, COUNT(*) AS pocet_komentaru
FROM it_web_magazine1.komentare
GROUP BY uzivatel_id
ORDER BY uzivatel_id;


-- ----------------------------------------------------------------------------------
-- 6. SPOJOVÁNÍ TABULEK (JOIN)
-- ----------------------------------------------------------------------------------

-- INNER JOIN: Komentáře a jejich autoři
SELECT it_web_magazine1.komentare.obsah, it_web_magazine1.uzivatele.prezdivka
FROM it_web_magazine1.komentare
JOIN it_web_magazine1.uzivatele ON it_web_magazine1.komentare.uzivatel_id = it_web_magazine1.uzivatele.uzivatele_id;

-- RIGHT JOIN: Vozidla a jejich možné výhry
SELECT insane_racing1.vyhry.vyhra_id, insane_racing1.vozidla.nazev, insane_racing1.vyhry.poznamka
FROM insane_racing1.vyhry
RIGHT JOIN insane_racing1.vozidla ON insane_racing1.vozidla.vozidlo_id = insane_racing1.vyhry.vozidla_id;

-- Složitější JOIN s filtrováním
SELECT it_web_magazine1.clanky.publikovano, it_web_magazine1.clanky.titulek, it_web_magazine1.uzivatele.prezdivka
FROM it_web_magazine1.clanky
JOIN it_web_magazine1.uzivatele ON it_web_magazine1.clanky.autor_id = it_web_magazine1.uzivatele.uzivatele_id
WHERE it_web_magazine1.clanky.publikovano >= '2010-01-01'
  AND it_web_magazine1.clanky.klicova_slova LIKE '%hra%';


-- ----------------------------------------------------------------------------------
-- 7. PODDOTAZY (SUBQUERIES)
-- ----------------------------------------------------------------------------------

-- Výběr článků konkrétního autora pomocí poddotazu
SELECT c.titulek
FROM it_web_magazine1.clanky AS c
WHERE c.autor_id IN (
    SELECT u.uzivatele_id
    FROM it_web_magazine1.uzivatele AS u
    WHERE u.prezdivka = 'DENNY'
);

-- Kontrola konzistence: Kódy bank, které chybí v číselníku
SELECT *
FROM simple_money1.bank_account AS ba
WHERE ba.bank_code NOT IN (
    SELECT bc.bank_code
    FROM simple_money1.bank_code AS bc
);

-- Analýza aktivních uživatelů
SELECT it_web_magazine1.komentare.clanek_id, it_web_magazine1.komentare.obsah AS KOMENTAR, it_web_magazine1.uzivatele.prezdivka AS AUTOR
FROM it_web_magazine1.komentare
JOIN it_web_magazine1.uzivatele ON it_web_magazine1.komentare.uzivatel_id = it_web_magazine1.uzivatele.uzivatele_id
WHERE (it_web_magazine1.uzivatele.prezdivka = 'david' OR it_web_magazine1.uzivatele.prezdivka = 'EMA')
  AND it_web_magazine1.komentare.clanek_id <= 2
ORDER BY it_web_magazine1.komentare.clanek_id;

-- ----------------------------------------------------------------------------------
-- 8. ULOŽENÉ PROCEDURY (PROCEDURES)
-- ----------------------------------------------------------------------------------

-- 1) Procedura FindThief: Vyhledání autora článku podle klíčového slova v popisu
DELIMITER $

CREATE PROCEDURE it_web_magazine1.FindThief(
    IN hledane_slovo VARCHAR(10)
)
BEGIN
    SELECT u.prezdivka
    FROM it_web_magazine1.clanky AS c
             JOIN it_web_magazine1.uzivatele AS u ON c.autor_id = u.uzivatele_id
    WHERE c.popis LIKE CONCAT('%', hledane_slovo, '%');
END $

DELIMITER ;


-- 2) Procedura SelectCar: Výběr nejrychlejšího vozidla do určité hmotnosti
DELIMITER $

CREATE PROCEDURE insane_racing1.SelectCar()
BEGIN
    SELECT *
    FROM insane_racing1.vozidla
    WHERE hmotnost < 3000
    ORDER BY max_rychlost DESC
    LIMIT 1;
END $

DELIMITER ;

-- 3) Procedura ToJeBordel: Vyhledání nejlevnějšího produktu podle názvu
DELIMITER $

CREATE PROCEDURE simple_money1.ToJeBordel(
    IN priblizny_nazev_produktu VARCHAR(60)
)
BEGIN
    SELECT * FROM simple_money1.item
    WHERE title LIKE CONCAT('%', priblizny_nazev_produktu, '%')
    ORDER BY price ASC
    LIMIT 1;
END $

DELIMITER ;

-- 4) Procedura Zlodej: Kompletní informace o uživateli a jeho článku s klíčovým slovem
DELIMITER $

CREATE PROCEDURE it_web_magazine1.Zlodej(
    IN jmeno VARCHAR(60)
)
BEGIN
    SELECT c.*, u.*
    FROM it_web_magazine1.uzivatele AS u
             JOIN it_web_magazine1.clanky AS c ON u.uzivatele_id = c.autor_id
    WHERE u.prezdivka = jmeno AND c.popis LIKE '%mouse%';
END $

DELIMITER ;

-- 5) Procedura BohatyAVykutaleny: Výpočet sumy obdržených transakcí uživatele (INOUT parametr)
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

-- 6) Procedura VrabecVHrsti: Načtení detailů adresy uživatele do OUT proměnných
DELIMITER $

CREATE PROCEDURE simple_money1.VrabecVHrsti(
    IN id_uzivatele INT,
    OUT adresa_cislo INT,
    OUT ulice VARCHAR(60),
    OUT registrace_cislo INT,
    OUT dum_cislo INT,
    OUT mesto VARCHAR(60),
    OUT psc INT
)
BEGIN
    SELECT a.address_id, a.street, a.registry_number, a.house_number, a.city, a.zip
    INTO adresa_cislo, ulice, registrace_cislo, dum_cislo, mesto, psc
    FROM simple_money1.person AS p
             JOIN simple_money1.address AS a ON p.address_id = a.address_id
    WHERE p.person_id = id_uzivatele;
END $

DELIMITER ;

-- 7) Procedura ZmetourJeden: Podmíněné větvení IF-ELSE na základě přezdívky uživatele
DELIMITER $

CREATE PROCEDURE it_web_magazine1.ZmetourJeden(
    IN p_id_uzivatele INT,
    OUT jaky_je VARCHAR(30)
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

-- 8) Procedura JsiNahranyChlapce: Vynulování částek transakcí a vrácení nového součtu
DELIMITER $

CREATE PROCEDURE insane_racing1.JsiNahranyChlapce(
    IN id_uzivatele INT,
    OUT prasulky INT
)
BEGIN
    UPDATE insane_racing1.transakce
    SET castka = 0
    WHERE uzivatel_id = id_uzivatele AND stav = 'obdrzeno';

    SET prasulky = (
        SELECT SUM(castka)
        FROM insane_racing1.transakce
        WHERE uzivatel_id = id_uzivatele AND stav = 'obdrzeno'
    );
END $

DELIMITER ;

-- 9) Procedura vyberProdukt: Vyhledání nejdražšího produktu v cenovém rozmezí
DELIMITER $

CREATE PROCEDURE simple_money1.vyberProdukt(
    IN hledany_produkt VARCHAR(60),
    IN cena_min INT,
    IN cena_max INT,
    OUT produkt VARCHAR(160),
    OUT cena INT
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