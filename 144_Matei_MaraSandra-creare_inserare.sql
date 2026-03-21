CREATE SEQUENCE seq_id_reclama
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_sponsor
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_premiu
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_angajat
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_stapan
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_caine
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_proba
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_bilet
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE SEQUENCE seq_id_spectator
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    NOCACHE;

CREATE TABLE sponsor (
    id_sponsor NUMBER PRIMARY KEY,
    nume VARCHAR2(255),
    email VARCHAR2(255) UNIQUE
);

CREATE TABLE reclama (
    id_reclama NUMBER PRIMARY KEY,
    id_sponsor NUMBER,
    CONSTRAINT fk_reclama_sponsor FOREIGN KEY (id_sponsor) REFERENCES sponsor(id_sponsor)
);

CREATE TABLE angajat (
    id_angajat NUMBER PRIMARY KEY,
    nume VARCHAR2(255),
    telefon VARCHAR2(20) UNIQUE,
    email VARCHAR2(255) UNIQUE,
    salariu NUMBER
);

CREATE TABLE jurat (
    id_angajat NUMBER,
    CONSTRAINT id_jurat PRIMARY KEY (id_angajat),
    CONSTRAINT fk_jurat_angajat FOREIGN KEY (id_angajat) REFERENCES angajat(id_angajat)
);

CREATE TABLE staff (
    id_angajat NUMBER,
    CONSTRAINT id_staff PRIMARY KEY (id_angajat),
    CONSTRAINT fk_staff_angajat FOREIGN KEY (id_angajat) REFERENCES angajat(id_angajat)
);

CREATE TABLE stapan (
    id_stapan NUMBER PRIMARY KEY,
    nume VARCHAR2(255),
    telefon VARCHAR2(20) UNIQUE
);

CREATE TABLE catel (
    id_caine NUMBER PRIMARY KEY,
    nume VARCHAR2(255),
    rasa VARCHAR2(255),
    id_stapan NUMBER,
    CONSTRAINT fk_catel_stapan FOREIGN KEY (id_stapan) REFERENCES stapan(id_stapan)
);

CREATE TABLE premiu (
    id_premiu NUMBER PRIMARY KEY,
    tip_premiu VARCHAR2(20) CHECK (tip_premiu IN ('loc1', 'loc2', 'loc3' ,'special', 'eleganta', 'participare')),
    suma_de_bani NUMBER,
    id_sponsor NUMBER,
    CONSTRAINT fk_premiu_sponsor FOREIGN KEY (id_sponsor) REFERENCES sponsor(id_sponsor),
    id_jurat NUMBER,
    CONSTRAINT fk_premiu_jurat FOREIGN KEY (id_jurat) REFERENCES jurat(id_angajat),
    id_caine NUMBER,
    CONSTRAINT fk_premiu_caine FOREIGN KEY (id_caine) REFERENCES catel(id_caine)
);

CREATE TABLE proba (
    id_proba NUMBER PRIMARY KEY,
    tip_proba VARCHAR2(20) CHECK (tip_proba IN ('caracteristici', 'atitudine', 'mers'))
);

CREATE TABLE participare (
    id_caine NUMBER,
    id_proba NUMBER,
    CONSTRAINT pk_participare PRIMARY KEY (id_caine, id_proba),
    CONSTRAINT fk_participare_caine FOREIGN KEY (id_caine) REFERENCES catel(id_caine),
    CONSTRAINT fk_participare_proba FOREIGN KEY (id_proba) REFERENCES proba(id_proba)
);

CREATE TABLE bilet (
    id_bilet NUMBER PRIMARY KEY,
    numar NUMBER,
    tip_bilet VARCHAR2(20) CHECK (tip_bilet IN ('caracteristici', 'atitudine', 'mers')),
    pret NUMBER NULL
);

CREATE TABLE spectator (
    id_spectator NUMBER PRIMARY KEY,
    nume VARCHAR2(255)
);

CREATE TABLE achizitie (
    id_bilet NUMBER,
    id_spectator NUMBER,
    CONSTRAINT pk_achizitie PRIMARY KEY (id_bilet, id_spectator),
    CONSTRAINT fk_achizitie_bilet FOREIGN KEY (id_bilet) REFERENCES bilet(id_bilet),
    CONSTRAINT fk_achizitie_spectator FOREIGN KEY (id_spectator) REFERENCES spectator(id_spectator)
);

-- 1. Să se completeze cardinalitățile 
-- și să se implementeze relația spectator apreciază cățel.

-- relatie many to many
-- un spectator poate aprecia mai multi catei
-- un catel poate fi apreciat de mai multi spectatori
-- => tabel bonus APRECIERE 
-- => catel-apreciere one-many, spectator-apreciere one-many
CREATE TABLE apreciere (
    id_spectator NUMBER,
    id_caine NUMBER,
    rating NUMBER CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT pk_apreciere PRIMARY KEY (id_spectator, id_caine),
    CONSTRAINT fk_apreciere_spectator FOREIGN KEY (id_spectator) REFERENCES spectator(id_spectator),
    CONSTRAINT fk_apreciere_caine FOREIGN KEY (id_caine) REFERENCES catel(id_caine)
);

-- 2. Să se insereze în acest tabel, folosind un select, 
-- date cu rating 5 pentru toți utilizatori care au avut 
-- bilet și toți cățelușii care au participat la probe cu 
-- tipul ....
-- spectator achizitie bilet proba participare
INSERT INTO apreciere (id_spectator, id_caine, rating)
SELECT DISTINCT s.id_spectator, pa.id_caine, 5
FROM spectator s
JOIN achizitie a ON s.id_spectator = a.id_spectator
JOIN bilet b ON a.id_bilet = b.id_bilet AND b.tip_bilet = 'mers'
JOIN proba pr ON pr.tip_proba = 'mers'
JOIN participare pa ON pr.id_proba = pa.id_proba;

INSERT INTO sponsor VALUES (seq_id_sponsor.NEXTVAL, 'Royal Canin', 'contact@royalcanin.com');
INSERT INTO sponsor VALUES (seq_id_sponsor.NEXTVAL, 'Pet Resort', 'contact@petresort.com');
INSERT INTO sponsor VALUES (seq_id_sponsor.NEXTVAL, 'Animal Society', 'contact@animalsociety.com');
INSERT INTO sponsor VALUES (seq_id_sponsor.NEXTVAL, 'Nutricanis', 'contact@nutricanis.com');
INSERT INTO sponsor VALUES (seq_id_sponsor.NEXTVAL, 'Dog Resort', 'contact@dogresort.com');
INSERT INTO sponsor VALUES (seq_id_sponsor.NEXTVAL, 'Dog-Spa', 'contact@dogspa.com');

INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 1);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 1);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 1);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 2);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 4);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 5);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 5);
INSERT INTO reclama VALUES (seq_id_reclama.NEXTVAL, 6);

INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Luz Noceda', '0722333444', 'owlhouse@gmail.com', 3000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Jon Snow', '0722333443', 'jonsnow@gmail.com', 2000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Alexander Hamilton', '0722333442', 'hamilton@gmail.com', 3000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Peter Parker', '0722333441', 'friendlyspider@gmail.com', 3000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Kobeni Higashiyama', '0722333440', 'kobeni@gmail.com', 2000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Gandalf Grey', '0722333449', 'wizard@gmail.com', 1000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Stan Pines', '0722333448', 'mysteryshack@gmail.com', 3000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Ion Glanetasu', '0722333447', 'pamant@pamant.com', 2000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Viktor Frankenstein', '0722333446', 'frank@gmail.com', 3000);

INSERT INTO staff VALUES (1);
INSERT INTO staff VALUES (2);
INSERT INTO staff VALUES (3);
INSERT INTO staff VALUES (4);
INSERT INTO staff VALUES (5);
INSERT INTO staff VALUES (6);
INSERT INTO staff VALUES (7);
INSERT INTO staff VALUES (8);
INSERT INTO staff VALUES (9);

INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Doctor Doofenschmirtz', '0711233445', 'heinzdoofenshmirtz@evil.inc.com', 4000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Perry Platypus', '0711233446', 'aplatypus@gmail.com', 4300);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Bruce Wayne', '0722233447', 'batman@gmail.com', 4000);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Leia Organa', '0722233448', 'starwars@gmail.com', 4300);
INSERT INTO angajat VALUES (seq_id_angajat.NEXTVAL, 'Misa Amane', '0722233449', 'misamisa@gmail.com', 4300);

INSERT INTO jurat VALUES (10);
INSERT INTO jurat VALUES (11);
INSERT INTO jurat VALUES (12);
INSERT INTO jurat VALUES (13);
INSERT INTO jurat VALUES (14);

INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Light Yagami', '0722233442');
INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Daenerys Targaryen', '0722233441');
INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Homura Akemi', '0722233440');
INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Shaggy Rogers', '0722233443');
INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Nona Ninth', '0722233444');
INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Hiccup Haddock', '0712233445');
INSERT INTO stapan VALUES (seq_id_stapan.NEXTVAL, 'Theo Light', '0712233446');

INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Ryuk', 'shiba inu', 1);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Drogon', 'chihuahua', 2);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Kyubey', 'pisica', 3);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Scooby-Doo', 'dog german', 4);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Noodle', 'borzoi', 5);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Toothless', 'labrador', 6);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Tiger', 'tigru', 7);
INSERT INTO catel VALUES (seq_id_caine.NEXTVAL, 'Berry', 'pisica', 7);

INSERT INTO proba VALUES (seq_id_proba.NEXTVAL, 'caracteristici');
INSERT INTO proba VALUES (seq_id_proba.NEXTVAL, 'atitudine');
INSERT INTO proba VALUES (seq_id_proba.NEXTVAL, 'mers');

INSERT INTO participare VALUES (1, 1);
INSERT INTO participare VALUES (2, 1);
INSERT INTO participare VALUES (2, 2);
INSERT INTO participare VALUES (2, 3);
INSERT INTO participare VALUES (3, 2);
INSERT INTO participare VALUES (4, 1);
INSERT INTO participare VALUES (4, 2);
INSERT INTO participare VALUES (4, 3);
INSERT INTO participare VALUES (5, 1);
INSERT INTO participare VALUES (5, 2);
INSERT INTO participare VALUES (5, 3);
INSERT INTO participare VALUES (6, 1);
INSERT INTO participare VALUES (6, 3);
INSERT INTO participare VALUES (7, 2);
INSERT INTO participare VALUES (7, 3);
INSERT INTO participare VALUES (8, 2);

INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'loc1', 1000, 1, 10, 7);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'loc2', 500, 2, 11, 4);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'loc3', 250, 3, 12, 6);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'special', 100, 4, 13, 6);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'eleganta', 50, 5, 14, 5);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'participare', 25, 6, 12, 1);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'participare', 25, 6, 12, 2);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'participare', 25, 6, 12, 3);
INSERT INTO premiu VALUES (seq_id_premiu.NEXTVAL, 'participare', 25, 6, 12, 8);

INSERT INTO spectator VALUES (seq_id_spectator.NEXTVAL, 'Harleen Quinzel');
INSERT INTO spectator VALUES (seq_id_spectator.NEXTVAL, 'Pamela Isley');
INSERT INTO spectator VALUES (seq_id_spectator.NEXTVAL, 'Mina Harker');
INSERT INTO spectator VALUES (seq_id_spectator.NEXTVAL, 'Paul Atreides');
INSERT INTO spectator VALUES (seq_id_spectator.NEXTVAL, 'Jon Arbuckle');

INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 1, 'caracteristici', 50);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 1, 'atitudine', 15);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 1, 'mers', 20);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 2, 'caracteristici', 80);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 2, 'atitudine', 30);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 2, 'mers', 40);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 3, 'caracteristici', 120);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 3, 'atitudine', 40);
INSERT INTO bilet VALUES (seq_id_bilet.NEXTVAL, 3, 'mers', 50);

INSERT INTO achizitie VALUES (1, 4);
INSERT INTO achizitie VALUES (2, 4);
INSERT INTO achizitie VALUES (4, 1);
INSERT INTO achizitie VALUES (5, 1);
INSERT INTO achizitie VALUES (3, 2);
INSERT INTO achizitie VALUES (2, 3);
INSERT INTO achizitie VALUES (4, 3);
INSERT INTO achizitie VALUES (7, 5);
INSERT INTO achizitie VALUES (8, 5);
INSERT INTO achizitie VALUES (9, 5);