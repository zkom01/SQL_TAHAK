# 📚 MySQL Tahák & Řešené úlohy

Studijní materiál pokrývající práci s MySQL/MariaDB – od základní manipulace s daty až po pohledy, triggery a poddotazy. Součástí jsou tři cvičné databáze pro procvičování dotazů v reálném prostředí.

---

## 📁 Struktura projektu

```
SQL_TAHAK/
├── MySQL_tahák.sql      # Komplexní průvodce MySQL s komentovanými příklady
├── Resene_ukoly.sql     # Sbírka řešených úloh napříč všemi třemi databázemi
└── databaze/
    ├── insane_racing.sql        # Závodní databáze – původní stav
    ├── insane_racing._edit.sql  # Závodní databáze – upravená verze
    ├── it_web_magazine.sql      # Databáze IT magazínu – původní stav
    ├── it_web_magazine_edit.sql # Databáze IT magazínu – upravená verze
    ├── simple_money.sql         # Finanční databáze – původní stav
    └── simple_money_edit.sql    # Finanční databáze – upravená verze
```

---

## 🗂️ MySQL_tahák.sql – obsah

| Sekce | Téma |
|---|---|
| 1 | Nastavení prostředí (`CREATE DATABASE`, `USE`) |
| 2 | Tvorba tabulek – DDL (`CREATE TABLE`, datové typy, `FOREIGN KEY`) |
| 3 | Manipulace s daty – DML (`INSERT`, `UPDATE`, `DELETE`) |
| 4 | Dotazy, filtrování a řazení (`SELECT`, `WHERE`, `LIKE`, `ORDER BY`) |
| 5 | Agregační funkce a seskupování (`COUNT`, `AVG`, `GROUP BY`, `HAVING`) |
| 6 | Spojování tabulek (`INNER JOIN`, `LEFT JOIN`) |
| 7 | Pohledy – Views (`CREATE VIEW`) |
| 8 | Automatizace – Triggery (`BEFORE INSERT`, `SIGNAL SQLSTATE`) |
| 9 | Údržba a čištění (deaktivace vs. smazání záznamu, `ON DELETE CASCADE`) |

---

## ✅ Resene_ukoly.sql – obsah

| Sekce | Téma |
|---|---|
| 1 | Jednoduché příklady – `INSERT`, `UPDATE`, `DELETE` |
| 2 | Pokročilé příklady – hromadné vložení, podmíněné mazání |
| 3 | Bonus – náročnější úlohy kombinující více operací |
| 4 | Výběr dat – `SELECT`, `LIKE`, `IN`, `BETWEEN` |
| 5 | Řazení, agregace a seskupování |
| 6 | Spojování tabulek – `INNER JOIN`, `RIGHT JOIN` |
| 7 | Poddotazy – `Subqueries` v `WHERE` a `IN` |

---

## 🗄️ Cvičné databáze

### `insane_racing`
Závodní databáze. Obsahuje tabulky pro vozidla, turnaje, výhry a měny. Vhodná pro procvičování `JOIN`, `UPDATE` s podmínkami a agregací.

Klíčové tabulky: `vozidla`, `turnaje`, `vyhry`, `meny`

### `it_web_magazine`
Databáze IT magazínu. Obsahuje uživatele, články a komentáře propojené cizími klíči. Vhodná pro procvičování `JOIN` mezi třemi tabulkami, poddotazů a filtrování textu.

Klíčové tabulky: `uzivatele`, `clanky`, `komentare`

### `simple_money`
Velká finanční databáze s tisíci záznamy. Obsahuje uživatele, adresy, bankovní účty a produkty. Vhodná pro procvičování výkonnostních dotazů, `BETWEEN`, `IN` a kontroly konzistence dat.

Klíčové tabulky: `user`, `address`, `bank_account`, `bank_code`, `item`

---

## 🚀 Jak začít

### 1. Naimportuj databáze

V phpMyAdmin nebo přes příkazovou řádku:

```bash
mysql -u root -p < databaze/it_web_magazine.sql
mysql -u root -p < databaze/insane_racing.sql
mysql -u root -p < databaze/simple_money.sql
```

### 2. Otevři tahák

Soubor `MySQL_tahák.sql` otevři v libovolném SQL editoru (DBeaver, HeidiSQL, phpMyAdmin, VS Code s rozšířením). Příklady jsou samostatné – spouštěj je postupně po sekcích.

### 3. Procvičuj na řešených úlohách

Soubor `Resene_ukoly.sql` odkazuje na databáze prefixem schématu (např. `it_web_magazine1.uzivatele`). Uprav název schématu podle toho, jak jsi databáze naimportoval.

---

## 💡 Tipy

Před spuštěním `DELETE` nebo `UPDATE` vždy nejdřív spusť odpovídající `SELECT` se stejnou podmínkou `WHERE` a zkontroluj, které záznamy budou zasaženy.

Při práci se soubory `_edit` se doporučuje mít původní verzi databáze jako zálohu – snadno obnovíš výchozí stav pro opakované procvičování.
