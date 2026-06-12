# Sama skeem kahes DBMS-is — PostgreSQL vs MySQL/MariaDB

**Grupp:** TAK25 · **Mootorid:** PostgreSQL + MariaDB (MySQL-iga ühilduv) · **Platvorm:** Fedora Linux (mitte konteiner)
**Video pikkus:** 8–12 min · **Salvestus:** Zoom / OBS (jaga ainult terminali akent, font ~16pt)

> Eesmärk: luua **täpselt sama andmebaasi struktuur** kahes erinevas relatsioonilises mootoris,
> sisestada samad andmed, teha mõlemas päringuid ja **näidata vähemalt 2 konkreetset erinevust**.
>
> **[ÜTLE]** = mida räägid · **[KIRJUTA]** = mida terminali tipid.
> Vaikseid ootamise kohti (paigaldus) lõika pärast LosslessCutiga välja.

> 💡 **Miks MariaDB "MySQL-i" asemel?** MariaDB on MySQL-i otsene haru (fork) ja räägib sama SQL-i.
> Fedoral käivitub ta kohe ja `sudo mysql` töötab ilma parooliprobleemideta. Kogu SQL on standardne
> MySQL-süntaks. Päris Oracle MySQL töötab identselt — vaata kõrvalmärkust paigalduse juures.

---

## 0:00 – 0:45 · Sissejuhatus

**[ÜTLE]**
> "Tere! Loon **sama andmebaasi struktuuri kahes mootoris** — PostgreSQL ja MySQL-iga ühilduv MariaDB.
> Mõlemasse teen andmebaasi *kool*, tabelid *klass* ja *opilane*, samade tüüpidega (sh üks DATE-väli),
> sisestan samad andmed, teen samad päringud ja näitan lõpus **konkreetseid erinevusi**. Alustan PostgreSQL-ist."

---

# OSA 1 — PostgreSQL

## 0:45 – 1:30 · Käivitan ja ühendun

**[ÜTLE]**
> "Kontrollin, et teenus käib, ja ühendun."

**[KIRJUTA]**
```bash
sudo systemctl enable --now postgresql
systemctl status postgresql --no-pager
sudo -u postgres psql
```
> *(Kui PostgreSQL pole paigaldatud: `sudo dnf install -y postgresql-server postgresql && sudo postgresql-setup --initdb`)*

**[ÜTLE]**
> "Viip `postgres=#` — ühendus toimib."

## 1:30 – 3:15 · Loon andmebaasi, tabelid, andmed, päringud

**[ÜTLE]**
> "Loon andmebaasi *kool*."

**[KIRJUTA]**
```sql
CREATE DATABASE kool;
\c kool
```

**[ÜTLE]**
> "Kaks tabelit. Pane tüübid tähele: `id` on automaatne number — Postgresis **SERIAL**; `synniaeg` on **DATE**, `aktiivne` **BOOLEAN**."

**[KIRJUTA]**
```sql
CREATE TABLE klass (
    id      INTEGER PRIMARY KEY,
    nimetus VARCHAR(10)
);

CREATE TABLE opilane (
    id             SERIAL PRIMARY KEY,
    nimi           VARCHAR(50),
    synniaeg       DATE,
    keskmine_hinne DECIMAL(3,1),
    aktiivne       BOOLEAN,
    klass_id       INTEGER REFERENCES klass(id)
);
```

**[ÜTLE]**
> "Samad näidisandmed, mida kasutan ka teises mootoris."

**[KIRJUTA]**
```sql
INSERT INTO klass (id, nimetus) VALUES (1, '10A'), (2, '11B');

INSERT INTO opilane (nimi, synniaeg, keskmine_hinne, aktiivne, klass_id) VALUES
('Mari Maasikas', '2008-04-15', 4.5, TRUE,  1),
('Jaan Tamm',     '2007-11-30', 3.8, TRUE,  2),
('Liis Lepik',    '2008-09-01', 4.2, FALSE, 1);
```

**[ÜTLE]**
> "Kaks päringut: kõik õpilased, ja DATE-väljaga — enne 2008. aastat sündinud."

**[KIRJUTA]**
```sql
SELECT * FROM opilane;
SELECT nimi, synniaeg FROM opilane WHERE synniaeg < '2008-01-01';
```

**[ÜTLE]**
> "Mõlemad töötavad. Postgres valmis — lähen MySQL-i."

**[KIRJUTA]**
```sql
\q
```

---

# OSA 2 — MySQL / MariaDB

## 3:15 – 4:15 · Paigaldan, käivitan ja ühendun

**[ÜTLE]**
> "Nüüd MariaDB, mis on MySQL-iga ühilduv. Paigaldan, käivitan, ühendun."

**[KIRJUTA]**
```bash
sudo dnf install -y mariadb-server
sudo systemctl enable --now mariadb
systemctl status mariadb --no-pager
sudo mysql
```

> 💡 **Päris Oracle MySQL-i variant:** `sudo dnf install -y community-mysql-server` →
> `sudo systemctl enable --now mysqld` → `sudo grep 'temporary password' /var/log/mysqld.log`
> (võta logist ajutine parool) → `mysql -u root -p` → `ALTER USER 'root'@'localhost' IDENTIFIED BY 'UusParool1!';`

**[ÜTLE]**
> "Viip `MariaDB [(none)]>` — ühendus toimib."

## 4:15 – 6:00 · Loon SAMA andmebaasi, tabelid, andmed, päringud

**[ÜTLE]**
> "Sama andmebaas *kool* — täpselt sama nimi."

**[KIRJUTA]**
```sql
CREATE DATABASE kool;
USE kool;
```

**[ÜTLE]**
> "Sama skeem ja tüübid. **Üks rida erineb:** automaatne id on siin **AUTO_INCREMENT**, mitte SERIAL — esimene erinevus. Ülejäänu sama."

**[KIRJUTA]**
```sql
CREATE TABLE klass (
    id      INT PRIMARY KEY,
    nimetus VARCHAR(10)
);

CREATE TABLE opilane (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    nimi           VARCHAR(50),
    synniaeg       DATE,
    keskmine_hinne DECIMAL(3,1),
    aktiivne       BOOLEAN,
    klass_id       INT,
    FOREIGN KEY (klass_id) REFERENCES klass(id)
);
```

**[ÜTLE]**
> "Täpselt samad andmed."

**[KIRJUTA]**
```sql
INSERT INTO klass (id, nimetus) VALUES (1, '10A'), (2, '11B');

INSERT INTO opilane (nimi, synniaeg, keskmine_hinne, aktiivne, klass_id) VALUES
('Mari Maasikas', '2008-04-15', 4.5, TRUE,  1),
('Jaan Tamm',     '2007-11-30', 3.8, TRUE,  2),
('Liis Lepik',    '2008-09-01', 4.2, FALSE, 1);
```

**[ÜTLE]**
> "Ja samad kaks päringut."

**[KIRJUTA]**
```sql
SELECT * FROM opilane;
SELECT nimi, synniaeg FROM opilane WHERE synniaeg < '2008-01-01';
```

**[ÜTLE]**
> "Samad tulemused nagu Postgresis — skeem on nähtavalt sama."

---

# OSA 3 — Erinevused (vähemalt 2)

## 6:00 – 7:00 · Erinevus 1 — automaatne id (SERIAL vs AUTO_INCREMENT)

**[ÜTLE]**
> "Esimene erinevus: automaatne id. Postgresis **SERIAL**, MySQL-is **AUTO_INCREMENT** — selle ühe rea pidin ümber kirjutama, kopeerida ei saanud.
> AUTO_INCREMENT on lühem ja loetavam; SERIAL loob taustal eraldi *sequence'i* ja annab rohkem kontrolli. **MySQL = mugavam, Postgres = paindlikum.**"

**[KIRJUTA]** *(näita mõlema tabeli struktuuri kõrvuti — vaheta aknaid)*
```sql
-- MySQL/MariaDB pool:
DESCRIBE opilane;
```

## 7:00 – 8:30 · Erinevus 2 — teksti tõstutundlikkus (collation)

**[ÜTLE]**
> "Teine erinevus on otse näha. Otsin nime 'mari maasikas' **väikeste tähtedega**, kuigi andmetes on suur algustäht."

**[KIRJUTA]** *(MySQL/MariaDB pool)*
```sql
SELECT * FROM opilane WHERE nimi = 'mari maasikas';
```
**[ÜTLE]**
> "MySQL **tagastab rea** — vaikecollation on tõstutundetu."

**[KIRJUTA]** *(PostgreSQL pool — `sudo -u postgres psql -d kool`)*
```sql
SELECT * FROM opilane WHERE nimi = 'mari maasikas';
```
**[ÜTLE]**
> "Postgres **ei tagasta midagi** — tema on tõstutundlik, 'mari' ≠ 'Mari'. **MySQL = mugav otsinguks, Postgres = täpsem ja ettearvatavam** (vajadusel `ILIKE`/`LOWER()`)."

## 8:30 – 9:15 · (Boonus) Erinevus 3 — BOOLEAN salvestus

**[ÜTLE]**
> "Kolmas erinevus: kirjutasin mõlemas `BOOLEAN`, aga salvestus erineb."

**[KIRJUTA]**
```sql
-- MySQL/MariaDB:
DESCRIBE opilane;                 -- aktiivne näitab tüüpi tinyint(1)
SELECT nimi, aktiivne FROM opilane;   -- väärtused 1 / 0
```
```sql
-- PostgreSQL:
\d opilane                         -- aktiivne näitab tüüpi boolean
SELECT nimi, aktiivne FROM opilane;   -- väärtused t / f
```
**[ÜTLE]**
> "MySQL teeb sellest `tinyint(1)` ja näitab 1/0 — sinna mahuks ka 5. Postgresil on päris boolean, t/f. **Postgres rangem, MySQL paindlikum, aga lohakam.**"

## 9:15 – 9:45 · Kokkuvõte

**[ÜTLE]**
> "Kokkuvõtteks: sama skeem, samad andmed ja samad päringud kahes mootoris. Kolm erinevust: SERIAL vs AUTO_INCREMENT, tõstutundlikkus ja BOOLEAN-i salvestus.
> Üldmulje: MySQL mugavam vaikimisi, Postgres rangem ja ettearvatavam. Aitäh!"

---

## Esitatavad failid (selles repos)
- `README.md` — see skript
- `postgres.sql` — PostgreSQL skript (skeem + andmed + päringud)
- `mysql.sql` — MySQL/MariaDB skript (skeem + andmed + päringud)
- `vordlus.md` — võrdlustekst (½–1 lk, vähemalt 2 erinevust)

## Skriptide käivitamine failist (valikuline)
```bash
# PostgreSQL:
sudo -u postgres psql -f postgres.sql

# MySQL/MariaDB:
sudo mysql < mysql.sql
```
