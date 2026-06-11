# Võrdlustekst: PostgreSQL vs MySQL/MariaDB

**Grupp: TAK25**

Lõin täpselt sama struktuuri mõlemas mootoris: andmebaas **kool**, tabelid **klass** ja
**opilane**, samade veergude ja andmetüüpidega (sh DATE-väli `synniaeg`), ning sisestasin
mõlemasse samad näidisandmed. Skeem õnnestus hoida peaaegu sõna-sõnalt identsena — erinevused
tulid välja kolmes konkreetses kohas, mille kõiki ma oma töö käigus reaalselt nägin.

## Erinevus 1 — automaatne ID (SERIAL vs AUTO_INCREMENT)

PostgreSQL-is kirjutasin automaatkasvava võtme `id SERIAL`, MySQL-is aga
`id INT AUTO_INCREMENT`. See tähendab, et ma **ei saanud sama CREATE TABLE lauset lihtsalt
kopeerida** — pidin selle ühe rea ümber kirjutama.

**Miks praktikas oluline:** kui andmebaasi kolitakse ühest mootorist teise, tuleb just sellised
read käsitsi kohandada. MySQL-i `AUTO_INCREMENT` on minu meelest loetavam ja lühem — kohe on näha,
et veerg kasvab ise. PostgreSQL-i `SERIAL` loob taustal eraldi *sequence*-objekti, mis annab
rohkem kontrolli: numbrijada saab eraldi lähtestada või mitme tabeli vahel jagada. **MySQL = mugavam,
PostgreSQL = paindlikum.**

## Erinevus 2 — teksti tõstutundlikkus (collation)

Otsisin mõlemast tabelist õpilast päringuga `WHERE nimi = 'mari maasikas'` (teadlikult väikeste
tähtedega), kuigi andmetes on `Mari Maasikas`. **MySQL/MariaDB tagastas rea**, sest tema vaikimisi
sortimisreegel (collation, nt `utf8mb4_general_ci`) on tõstutundetu. **PostgreSQL ei tagastanud
ühtegi rida**, sest tema võrdleb teksti tõstutundlikult — 'mari' ≠ 'Mari'.

**Miks praktikas oluline:** kasutaja otsingu (nt nime järgi) puhul on MySQL-i käitumine mugavam —
ei pea muretsema tähesuuruse pärast. Samas võib see peita vigu ja tekitada ootamatuid kokkulangevusi.
PostgreSQL on ettearvatavam ja täpsem: ta võrdleb täpselt nii, nagu kirjutad, ja kui soovin
tõstutundetut otsingut, ütlen seda ise (`ILIKE` või `LOWER(nimi) = 'mari maasikas'`). **MySQL =
mugav vaikimisi, PostgreSQL = täpne kontroll.**

## Erinevus 3 (boonus) — BOOLEAN salvestus

Kirjutasin mõlemas veeru `aktiivne BOOLEAN`, kuid salvestus erineb. MySQL muudab BOOLEAN-i tegelikult
tüübiks `tinyint(1)` ja näitab väärtusi `1`/`0` — sinna mahuks isegi väärtus 5, mis pole tõeväärtus.
PostgreSQL-il on **päris boolean-tüüp**, mis lubab ainult tõene/väär ja kuvab `t`/`f`. Siin on
PostgreSQL rangem ja tüübikindlam, MySQL paindlikum, aga lohakam.

## Kokkuvõte

Sama skeem töötas mõlemas mootoris ja andmed olid identsed. Erinevused on enamasti **mugavus vs
rangus**: MySQL/MariaDB kipub olema vaikimisi mugavam ja andestavam, PostgreSQL aga rangem,
ettearvatavam ja standardilähedasem. Praktikas tähendab see, et MySQL sobib kiireks alustamiseks ja
lihtsaks otsinguks, PostgreSQL aga olukorda, kus andmete täpsus ja ettearvatavus on tähtsam.
Kumbki pole absoluutselt parem — valik sõltub sellest, mida projekt vajab.
