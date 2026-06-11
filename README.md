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
> "Tere! Selles videos loon **sama andmebaasi struktuuri kahes erinevas andmebaasimootoris** — PostgreSQL ja MySQL-iga ühilduv MariaDB.
> Mõlemasse teen sama andmebaasi *kool*, samad tabelid *klass* ja *opilane*, samade veergude ja andmetüüpidega, sealhulgas ühe DATE-väljaga.
> Sisestan mõlemasse samad andmed, teen mõlemas päringuid ja lõpuks näitan **konkreetseid erinevusi**, mida ma töö käigus nägin — kus üks mootor on mugavam ja kus teine.
> Alustan PostgreSQL-ist."

---

# OSA 1 — PostgreSQL

## 0:45 – 1:30 · Käivitan ja ühendun

**[ÜTLE]**
> "Kontrollin, et PostgreSQL teenus töötab, ja ühendun. Kui teenust pole, käivitan selle."

**[KIRJUTA]**
```bash
sudo systemctl enable --now postgresql
systemctl status postgresql --no-pager
sudo -u postgres psql
```
> *(Kui PostgreSQL pole paigaldatud: `sudo dnf install -y postgresql-server postgresql && sudo postgresql-setup --initdb`)*

**[ÜTLE]**
> "Viip `postgres=#` näitab, et olen ühendatud — ühendus toimib."

## 1:30 – 3:15 · Loon andmebaasi, tabelid, andmed, päringud

**[ÜTLE]**
> "Loon andmebaasi *kool* ja lähen sinna sisse."

**[KIRJUTA]**
```sql
CREATE DATABASE kool;
\c kool
```

**[ÜTLE]**
> "Loon kaks tabelit. Pane tähele veergude tüüpe: `id` on automaatne number — PostgreSQL-is kirjutan selle **SERIAL**. `synniaeg` on **DATE**, `aktiivne` on **BOOLEAN**."

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
> "Sisestan samad näidisandmed, mida kasutan ka teises mootoris."

**[KIRJUTA]**
```sql
INSERT INTO klass (id, nimetus) VALUES (1, '10A'), (2, '11B');

INSERT INTO opilane (nimi, synniaeg, keskmine_hinne, aktiivne, klass_id) VALUES
('Mari Maasikas', '2008-04-15', 4.5, TRUE,  1),
('Jaan Tamm',     '2007-11-30', 3.8, TRUE,  2),
('Liis Lepik',    '2008-09-01', 4.2, FALSE, 1);
```

**[ÜTLE]**
> "Teen kaks päringut. Esimene tagastab kõik õpilased, teine kasutab DATE-välja — kõik, kes sündinud enne 2008. aastat."

**[KIRJUTA]**
```sql
SELECT * FROM opilane;
SELECT nimi, synniaeg FROM opilane WHERE synniaeg < '2008-01-01';
```

**[ÜTLE]**
> "Mõlemad päringud tagastavad tulemuse. PostgreSQL pool on valmis. Väljun ja lähen MySQL-i poole."

**[KIRJUTA]**
```sql
\q
```

---

# OSA 2 — MySQL / MariaDB

## 3:15 – 4:15 · Paigaldan, käivitan ja ühendun

**[ÜTLE]**
> "Nüüd MariaDB, mis on MySQL-iga ühilduv. Paigaldan serveri, käivitan teenuse ja ühendun."

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
> "Viip `MariaDB [(none)]>` näitab, et ühendus toimib."

## 4:15 – 6:00 · Loon SAMA andmebaasi, tabelid, andmed, päringud

**[ÜTLE]**
> "Teen sama andmebaasi *kool* — täpselt sama nimi nagu PostgreSQL-is."

**[KIRJUTA]**
```sql
CREATE DATABASE kool;
USE kool;
```

**[ÜTLE]**
> "Sama skeem, samad veerud, samad tüübid. **Üks rida on paratamatult erinev:** automaatne id — MySQL-is kasutan **AUTO_INCREMENT**, mitte SERIAL. See on esimene erinevus, mille juurde hiljem tulen. Ülejäänud tüübid — VARCHAR, DATE, DECIMAL, BOOLEAN — kirjutan sõna-sõnalt samamoodi."

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
> "Sisestan täpselt samad andmed."

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
> "Mõlemad tagastavad tulemuse, samad andmed nagu PostgreSQL-is. Skeem on mõlemas nähtavalt sama."

---

# OSA 3 — Erinevused (vähemalt 2)

## 6:00 – 7:00 · Erinevus 1 — automaatne id (SERIAL vs AUTO_INCREMENT)

**[ÜTLE]**
> "Esimene erinevus, mida ma juba nägin: **automaatne id-veerg kirjutatakse erinevalt.**
> PostgreSQL-is on see `SERIAL`, MySQL-is `AUTO_INCREMENT`. Ma ei saanud sama CREATE TABLE lauset lihtsalt kopeerida — pidin selle ühe rea ümber kirjutama.
> Kus kumb parem? MySQL-i `AUTO_INCREMENT` on minu meelest **loetavam ja lühem** — kohe näha, et veerg kasvab ise.
> PostgreSQL-i `SERIAL` loob taustal eraldi *sequence'i*, mis annab rohkem **kontrolli** — saan numbri jada eraldi hallata ja lähtestada. Üks on mugavam, teine paindlikum."

**[KIRJUTA]** *(näita mõlema tabeli struktuuri kõrvuti — vaheta aknaid)*
```sql
-- MySQL/MariaDB pool:
DESCRIBE opilane;
```

## 7:00 – 8:30 · Erinevus 2 — teksti tõstutundlikkus (collation)

**[ÜTLE]**
> "Teine erinevus on minu lemmik, sest see on otse näha. Otsin mõlemast õpilast nimega 'mari maasikas' — **kirjutan teadlikult väikeste tähtedega**, kuigi andmetes on 'Mari Maasikas' suure algustähega."

**[KIRJUTA]** *(MySQL/MariaDB pool)*
```sql
SELECT * FROM opilane WHERE nimi = 'mari maasikas';
```
**[ÜTLE]**
> "MySQL **tagastab rea** — talle ei lähe tähesuurus korda, sest vaikimisi sortimisreegel on tõstutundetu."

**[KIRJUTA]** *(PostgreSQL pool — `sudo -u postgres psql -d kool`)*
```sql
SELECT * FROM opilane WHERE nimi = 'mari maasikas';
```
**[ÜTLE]**
> "PostgreSQL **ei tagasta ühtegi rida** — tema on tõstutundlik ja 'mari' ei ole sama mis 'Mari'.
> Kus kumb parem? MySQL on **mugavam kasutaja otsingu jaoks** — ei pea muretsema tähesuuruse pärast.
> PostgreSQL on **ettearvatavam ja täpsem** — ta võrdleb täpselt nii, nagu kirjutad, ja kui tahan tõstutundetut otsingut, ütlen seda ise (`ILIKE` või `LOWER()`). Üks on mugav vaikimisi, teine annab täpse kontrolli."

## 8:30 – 9:15 · (Boonus) Erinevus 3 — BOOLEAN salvestus

**[ÜTLE]**
> "Veel üks erinevus, mille märkasin: kirjutasin mõlemas `aktiivne BOOLEAN`, aga salvestus on erinev."

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
> "MySQL muudab BOOLEAN-i tegelikult väikeseks täisarvuks `tinyint(1)` ja näitab 1 või 0. Sinna mahuks ka näiteks 5, mis pole päris tõeväärtus.
> PostgreSQL-il on **päris boolean-tüüp**, mis lubab ainult tõene/väär ja näitab t/f. Siin on PostgreSQL **rangem ja turvalisem**, MySQL **paindlikum, aga lohakam**."

## 9:15 – 9:45 · Kokkuvõte

**[ÜTLE]**
> "Kokkuvõtteks: lõin sama skeemi — andmebaas *kool*, tabelid *klass* ja *opilane*, samad veerud, tüübid ja DATE-väli — kahes mootoris, sisestasin samad andmed ja tegin samad päringud.
> Nägin kolme erinevust: automaatne id (SERIAL vs AUTO_INCREMENT), teksti tõstutundlikkus ja BOOLEAN-i salvestus.
> Üldmulje: MySQL on tihti **mugavam vaikimisi**, PostgreSQL **rangem ja ettearvatavam**. Aitäh!"

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
