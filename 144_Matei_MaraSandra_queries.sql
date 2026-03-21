-- 12. 5 cereri SQL.
-- a) subcereri sincronizate în care intervin cel puțin 3 tabele
-- f) utilizarea a cel puțin 1 bloc de cerere (clauza WITH)
WITH notpart AS ( 
    SELECT p.id_premiu
    FROM premiu p
    WHERE p.tip_premiu != 'participare'
)
SELECT 
    c.nume AS nume_caine,
    (
        SELECT s.nume || ' --- ' || a.nume
        FROM premiu p
        JOIN sponsor s ON p.id_sponsor = s.id_sponsor
        JOIN jurat j ON p.id_jurat = j.id_angajat
        JOIN angajat a ON j.id_angajat = a.id_angajat
        WHERE p.id_caine = c.id_caine AND p.id_premiu in (SELECT * FROM notpart)
        FETCH FIRST 1 ROWS ONLY
    ) AS sponsor_si_jurat
FROM catel c
WHERE EXISTS (
    SELECT 1 FROM premiu p WHERE p.id_caine = c.id_caine AND p.id_premiu in (SELECT * FROM notpart)
);
-- Pentru fiecare caine cu cel puțin un premiu care nu este un premiu de participare, 
-- sa se afișeze juratul și sponsorul care au acordat unul dintre premiile respective.

-- b) subcereri nesincronizate în clauza FROM
SELECT nume, COUNT(id_premiu) FROM (
    SELECT DISTINCT
        s.nume nume, p.id_premiu id_premiu FROM reclama r
        INNER JOIN sponsor s ON r.id_sponsor = s.id_sponsor
        INNER JOIN premiu p ON s.id_sponsor = p.id_sponsor
) GROUP BY nume;
-- Să se afle câte premii au dat toți sponsorii care au cel puțin o reclamă.

-- c) grupări de date, funcții grup, filtrate la nivel de grupuri cu subcereri nesincronizate
-- în clauza HAVING
SELECT
s.nume, SUM(p.suma_de_bani)
FROM catel c
  INNER JOIN stapan s ON s.id_stapan = c.id_stapan
  INNER JOIN premiu p ON p.id_caine = c.id_caine 
GROUP BY s.id_stapan, s.nume
HAVING COUNT(p.id_premiu) < 3;
-- Să se afle cați bani au câștigat stăpânii cu mai puțin de 3 premii per total de pe câinii lor.

-- d) ordonări și utilizarea funcțiilor NVL și DECODE în aceiasi cerere
SELECT SUM(
  NVL(pret, 0) *
  DECODE(tip_bilet,
    'caracteristici', 1,
    'mers', 2,
    'atitudine', 3
  )) suma FROM bilet;
-- Să se calculeze prețul total al biletelor, 
-- dacă ar fi dublat prețul celor de "mers" și triplat celor de "atitudine".

-- e) utilizarea a cel puțin 2 funcții pe șiruri de caractere, 2 funcții pe date, o expresie CASE
SELECT
  REPLACE(LOWER(nume), ' ', '_') || '_' || (
    CASE
    WHEN salariu < 2000 THEN '9'
    WHEN salariu < 3000 THEN '8'
    WHEN salariu < 4000 THEN '7'
    ELSE '6' END
  ) ||
  TO_CHAR(
    EXTRACT(YEAR FROM TRUNC(SYSDATE)) +
    TO_NUMBER(SUBSTR(telefon, 9, 2))) username
FROM angajat;
-- Să se aloce fiecarui angajat un username format din numele lor în lowercase, separat de underline-uri, 
-- cu o cifră de control bazată pe salariul lor si un număr bazat pe anul în care se face generarea usernameurilor 
-- conform datei de sistem, trunchiata, și ultimele 2 cifre din numărul de telefon al angajatului.

-- 13. 3 operații de actualizare / suprimare
/*
DELETE FROM stapan
WHERE nume IN(
  SELECT nume FROM stapan
  WHERE LOWER(REGEXP_SUBSTR(nume, '[^ ]+', 1, 1)) LIKE '%ight');
-- Șterge toți stăpânii al căror prenume se termină cu "ight".

DELETE FROM sponsor
WHERE id_sponsor IN (
    SELECT id_sponsor
    FROM reclama
    GROUP BY id_sponsor
    HAVING COUNT(*) > 2
);
-- Șterge toți sponsorii care au mai mult de 2 reclame.

UPDATE angajat
SET salariu = salariu * 1.1
WHERE id_angajat IN (
    SELECT id_angajat 
    FROM angajat 
    WHERE nume != 'Ion Glanetasu'
);
*/
-- Crește salariul tuturor angajaților cu 10% în afară de al lui Ion Glanetașu.

-- 14. Vizualizare complexă.
CREATE OR REPLACE VIEW view_caini_castig AS
SELECT
    c.id_caine,
    c.nume AS nume_caine,
    c.rasa AS rasa_caine,
    s.nume AS nume_stapan,
    NVL((
        SELECT SUM(p.suma_de_bani)
        FROM premiu p
        WHERE p.id_caine = c.id_caine
    ), 0) AS bani_castigati 
FROM
    catel c
    JOIN stapan s ON c.id_stapan = s.id_stapan;
-- Afișează pentru fiecare câine și stăpânul său suma totală de bani câștigată din premii.
-- LMD permis - rasa_caine e updatable
UPDATE view_caini_castig
SET rasa_caine = 'ryukyu'
WHERE id_caine = 1;
-- LMD nepermis - bani_castigati nu e updatable
/*
UPDATE view_caini_castig
SET bani_castigati = 1000
WHERE id_caine = 1;
*/

SELECT * FROM view_caini_castig;

-- 15. Cereri.
-- outer-join pe minimum 4 tabele
SELECT
    c.nume AS nume_caine,
    s.nume AS nume_stapan,
    NVL(p.tip_premiu, 'FARA PREMIU') AS tip_premiu,
    NVL(sp.nume, 'FARA SPONSOR') AS nume_sponsor,
    NVL(a.nume, 'FARA JURAT') AS nume_jurat
FROM
    catel c
    INNER JOIN stapan s ON c.id_stapan = s.id_stapan
    LEFT JOIN premiu p ON c.id_caine = p.id_caine
    LEFT JOIN sponsor sp ON p.id_sponsor = sp.id_sponsor
    LEFT JOIN jurat j ON p.id_jurat = j.id_angajat
    LEFT JOIN angajat a ON j.id_angajat = a.id_angajat
WHERE
    NOT EXISTS (
        SELECT 1 FROM premiu p WHERE p.id_caine = c.id_caine AND p.tip_premiu = 'loc1'
    );
-- Să se afișeze pentru fiecare câine care nu a primit locul 1 nici o dată,
-- numele, stăpânul, tipul premiului câștigat,
-- numele sponsorului și numele juratului.

-- division
SELECT c.id_caine, c.nume
FROM catel c
WHERE NOT EXISTS (
    SELECT 1
    FROM proba pr
    WHERE NOT EXISTS (
        SELECT 1
        FROM participare pa
        WHERE pa.id_caine = c.id_caine
          AND pa.id_proba = pr.id_proba
    )
);
-- Să se afișeze câinii care au participat la toate probele.

-- analiza top-n
WITH nr_caini AS (
    SELECT COUNT(DISTINCT id_caine) AS N
    FROM premiu
    WHERE tip_premiu = 'participare'
)
SELECT s.id_sponsor, s.nume, SUM(p.suma_de_bani) AS total_cheltuit
FROM sponsor s
JOIN premiu p ON s.id_sponsor = p.id_sponsor
GROUP BY s.id_sponsor, s.nume
ORDER BY total_cheltuit DESC
FETCH FIRST (SELECT N FROM nr_caini) ROWS ONLY;
-- Să se afișeze primii N sponsori în funcție de banii cheltuiți pe reclame,
-- unde N este numărul de câini care au primit un premiu de participare.

-- 16. Optimizare cerere complexă.
SELECT
    c.id_caine,
    c.nume AS nume_caine,
    s.nume AS nume_stapan,
    NVL(SUM(p.suma_de_bani), 0) AS bani_castigati
FROM
    catel c
    LEFT JOIN stapan s ON c.id_stapan = s.id_stapan
    LEFT JOIN premiu p ON c.id_caine = p.id_caine
WHERE 
    SUBSTR(LOWER(c.nume), 1, 1) IN (
        'a','b','c','d','e','f','g','h','i','j','k','l','m'
    )
GROUP BY
    c.id_caine, c.nume, s.nume; 
-- Afișează pentru fiecare câine și stăpânul său suma totală de bani câștigată din premii,
-- dacă numele câinelui începe cu o literă din prima jumătate a alfabetului.
DROP INDEX IF EXISTS idx_caini_nume;
DROP INDEX IF EXISTS idx_catel_stapan;
DROP INDEX IF EXISTS idx_premiu_caine;

CREATE INDEX
    idx_caini_nume 
ON catel(nume);
CREATE INDEX 
    idx_catel_stapan
ON catel(id_stapan);
CREATE INDEX
    idx_premiu_caine
ON premiu(id_caine);

SELECT
    c.id_caine,
    c.nume AS nume_caine,
    s.nume AS nume_stapan,
    NVL(SUM(p.suma_de_bani), 0) AS bani_castigati
FROM
    catel c
    INNER JOIN stapan s ON c.id_stapan = s.id_stapan
    LEFT JOIN premiu p ON c.id_caine = p.id_caine
WHERE 
    c.nume >= 'A' AND c.nume < 'N'
GROUP BY
    c.id_caine, c.nume, s.nume; 
-- Aceeași cerere, optimizată, prin modificarea condiției de filtrare,
-- utilizarea indexilor și a unui INNER JOIN în loc de LEFT JOIN.