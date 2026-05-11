# Řešené úlohy MySQL/MariaDB - INSERT, UPDATE, DELETE

# Jednoduché příklady
# ----------------------------------------------------------------------------------
# Příklad na databázi článků
# Odstranění uživatele podle emailu z tabulky uzivatele.
DELETE FROM it_web_magazine1.uzivatele WHERE email = 'ema@centrum.cz';

# Příklad na databázi závodníků
# Přidání měny Bitcoin (zkratka BTC) s kurzem k USD.
INSERT INTO insane_racing1.meny (nazev, zkratka, kurz_vuci_USD)
    VALUE ('Bitcoin','BTC','0.00008');

# Příklad na databázi e-shopu
# Aktualizace názvu obce v tabulce address.
UPDATE simple_money1.address
SET city = 'Mikulow'
WHERE city = 'Mikulovice';

# Pokročilé příklady
# ----------------------------------------------------------------------------------
# Hromadné vložení uživatelů
INSERT INTO it_web_magazine1.uzivatele (prezdivka, email, heslo)
VALUES ('Antonín Nevrlý','antonevrly@email.cz','5ly_poas7#gf'),
       ('Marek Horák','iloveanime@gmail.com','6SA4Ap_s32$f');

# Omezení maximální rychlosti vozidel
UPDATE insane_racing1.vozidla
SET max_rychlost = 320
WHERE max_rychlost > 320;

# Odstranění specifických adres podle ulice a čísla popisného
DELETE FROM simple_money1.address
WHERE street = 'Hladná' AND (house_number = 13 OR house_number = 28);

# BONUS - Příklady pro náročné
# ----------------------------------------------------------------------------------
# Označení starších článků jako zastaralé
UPDATE it_web_magazine1.clanky
SET popis = 'Zastaralý'
WHERE publikovano <= '2005-01-01';

# Odstranění vozidel s nízkým hodnocením
DELETE FROM insane_racing1.vozidla WHERE nazev = 'Moped' AND hodnoceni <= 30;

# Zvýšení ceny produktu o fixní částku
UPDATE simple_money1.item
SET price = price + 100
WHERE product_id = 29;

# Výběr dat (SELECT)
# ----------------------------------------------------------------------------------
# Vyhledání uživatele podle přezdívky
SELECT * FROM it_web_magazine1.uzivatele WHERE prezdivka = 'Denny';

# Vyhledání turnajů podle vzoru názvu
SELECT nazev, start FROM insane_racing1.turnaje WHERE nazev LIKE '%Grand%Prix%';

# Filtrování s využitím IN a BETWEEN
SELECT * FROM it_web_magazine1.uzivatele WHERE uzivatele_id IN (2,3,4);
SELECT nazev FROM insane_racing1.vozidla WHERE nazev IN ('Sáně','Moped','Pickup');

# Vyhledávání podle délky a pozice znaků (LIKE masky)
SELECT name FROM simple_money1.user WHERE name LIKE '___o___';

# Řazení, Agregace a seskupování (ORDER BY, GROUP BY)
# ----------------------------------------------------------------------------------
# Seřazení uživatelů podle abecedy
SELECT prezdivka, email FROM it_web_magazine1.uzivatele ORDER BY prezdivka;

# Výpočet průměrné hodnoty
SELECT AVG(zrychleni) AS prumerne_zrychleni FROM insane_racing1.vozidla;

# Počet záznamů splňujících podmínku (včetně aliasu)
SELECT COUNT(*) AS pocet_zlutych_produktu FROM simple_money1.item
WHERE title LIKE ('%žlutá%') OR title LIKE ('%yellow%');

# Seskupení dat a výpočet počtu výskytů
SELECT uzivatel_id, COUNT(*) AS pocet_komentaru
FROM it_web_magazine1.komentare
GROUP BY uzivatel_id
ORDER BY uzivatel_id;

# Spojování tabulek (JOIN)
# ----------------------------------------------------------------------------------
# INNER JOIN: Komentáře a jejich autoři
SELECT it_web_magazine1.komentare.obsah, it_web_magazine1.uzivatele.prezdivka
FROM it_web_magazine1.komentare
JOIN it_web_magazine1.uzivatele ON uzivatel_id = uzivatele_id;

# RIGHT JOIN: Vozidla a jejich možné výhry (včetně vozidel bez výhry)
SELECT insane_racing1.vyhry.vyhra_id, insane_racing1.vozidla.nazev, insane_racing1.vyhry.poznamka
FROM insane_racing1.vyhry
RIGHT JOIN insane_racing1.vozidla ON insane_racing1.vozidla.vozidlo_id = insane_racing1.vyhry.vozidla_id;

# Složitější JOIN s filtrováním
SELECT it_web_magazine1.clanky.publikovano, it_web_magazine1.clanky.titulek, it_web_magazine1.uzivatele.prezdivka
FROM it_web_magazine1.clanky
JOIN it_web_magazine1.uzivatele ON it_web_magazine1.clanky.autor_id = it_web_magazine1.uzivatele.uzivatele_id
WHERE it_web_magazine1.clanky.publikovano >= '2010-01-01'
  AND it_web_magazine1.clanky.klicova_slova LIKE '%hra%';

# Poddotazy (Subqueries)
# ----------------------------------------------------------------------------------
# Výběr článků konkrétního autora pomocí poddotazu
SELECT c.titulek
FROM it_web_magazine1.clanky AS c
WHERE c.autor_id IN
      (SELECT u.uzivatele_id
       FROM it_web_magazine1.uzivatele AS u
       WHERE u.prezdivka = 'DENNY');

# Kontrola konzistence: Kódy bank, které chybí v číselníku
SELECT *
FROM simple_money1.bank_account AS ba
WHERE ba.bank_code NOT IN
      (SELECT bc.bank_code
       FROM simple_money1.bank_code AS bc);

# Analýza aktivních uživatelů (Aktivita u konkrétních článků)
SELECT it_web_magazine1.komentare.clanek_id, it_web_magazine1.komentare.obsah AS KOMENTAR, it_web_magazine1.uzivatele.prezdivka AS AUTOR
FROM it_web_magazine1.komentare
JOIN it_web_magazine1.uzivatele ON it_web_magazine1.komentare.uzivatel_id = it_web_magazine1.uzivatele.uzivatele_id
WHERE (it_web_magazine1.uzivatele.prezdivka = 'david' OR it_web_magazine1.uzivatele.prezdivka = 'EMA')
  AND it_web_magazine1.komentare.clanek_id <= 2
ORDER BY it_web_magazine1.komentare.clanek_id;