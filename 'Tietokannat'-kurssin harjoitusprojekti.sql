--TIETOKANNAN LUONTI 

CREATE TABLE Kurssi (
koodi TEXT PRIMARY KEY,
nimi TEXT,
op INTEGER CHECK (op > 0 )
);

CREATE TABLE Kurssikerta (
kurssikoodi TEXT NOT NULL,
alkupvm TEXT CHECK (date(alkupvm) > date('1900-01-01')) NOT NULL,
loppupvm TEXT CHECK (date(loppupvm) > date(alkupvm)) NOT NULL,
PRIMARY KEY(alkupvm, loppupvm, kurssikoodi),
FOREIGN KEY(kurssikoodi) REFERENCES Kurssi(koodi)
);

CREATE TABLE Luentokerta (
alku TEXT NOT NULL,
loppu TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
Lnimi TEXT NOT NULL,
pvm TEXT CHECK (date(pvm) BETWEEN date(alku) AND date(loppu)),
klo TEXT CHECK (time('24:00') > time(substr(klo,0,5)) > time('00:00')),
PRIMARY KEY(Lnimi, alku, loppu, kurssikoodi),
FOREIGN KEY(alku, loppu, kurssikoodi) REFERENCES Kurssikerta(alkupvm, loppupvm, kurssikoodi)
);

CREATE TABLE Harkkaryhmä (
alku TEXT NOT NULL,
loppu TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
harkkaID TEXT NOT NULL,
maxosallistujat INTEGER CHECK (maxosallistujat > 0),
PRIMARY KEY(harkkaID, alku, loppu, kurssikoodi),
FOREIGN KEY(alku, loppu, kurssikoodi) REFERENCES Kurssikerta(alkupvm, loppupvm, kurssikoodi)
);

CREATE TABLE Harkkakerta (
alku TEXT NOT NULL,
loppu TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
harkkaid TEXT NOT NULL,
Hnimi TEXT NOT NULL,
pvm TEXT CHECK (date(pvm) BETWEEN date(alku) AND date(loppu)),
klo TEXT CHECK (time('24:00' > time(substr(klo,0,5)) > time('00:00'))),
PRIMARY KEY(Hnimi, alku, loppu, kurssikoodi, harkkaid),
FOREIGN KEY(alku, loppu, kurssikoodi, harkkaid) REFERENCES Harkkaryhmä(alku, loppu, kurssikoodi, harkkaID)
);

CREATE TABLE Tentti (
kurssikoodi TEXT NOT NULL,
Tnimi TEXT NOT NULL,
pvm TEXT CHECK (date(pvm) > date('1900-01-01')),
klo TEXT CHECK (time('24:00') > time(substr(klo,0,5)) > time('00:00')),
PRIMARY KEY(Tnimi, kurssikoodi),
FOREIGN KEY(kurssikoodi) REFERENCES Kurssi(koodi)
);

CREATE TABLE Opiskelija (
opnro TEXT PRIMARY KEY,
nimi TEXT,
saika TEXT CHECK (saika > date('1900-01-01')),
sisäänpvm TEXT CHECK (date(sisäänpvm) > date(saika)),
opohjelma TEXT,
opoikeus INTEGER DEFAULT 7
);

CREATE TABLE Harkkailmo (
opnro TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
alku TEXT NOT NULL,
loppu TEXT NOT NULL,
harkkaid TEXT NOT NULL,
PRIMARY KEY(opnro, kurssikoodi, alku, loppu, harkkaid),
FOREIGN KEY(opnro) REFERENCES Opiskelija(opnro),
FOREIGN KEY(kurssikoodi, alku, loppu, harkkaid) REFERENCES Harkkaryhmä(kurssikoodi, alku, loppu, harkkaID)
);

CREATE TABLE Tenttiilmo (
opnro TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
Tnimi TEXT NOT NULL,
PRIMARY KEY(opnro, kurssikoodi, Tnimi),
FOREIGN KEY(opnro) REFERENCES Opiskelija(opnro),
FOREIGN KEY(kurssikoodi, Tnimi) REFERENCES Tentti(kurssikoodi, Tnimi)
);
CREATE TABLE Rakennus (
osoite TEXT PRIMARY KEY,
nimi TEXT
);
CREATE TABLE Sali (
huoneKoodi TEXT PRIMARY KEY,
istumapaikat INTEGER CHECK (istumapaikat > 0),
tenttipaikat INTEGER CHECK (tenttipaikat > 0),
osoite TEXT REFERENCES Rakennus(osoite) NOT NULL
);

CREATE TABLE Varuste (
tuotenro INTEGER CHECK (tuotenro > 0) PRIMARY KEY,
tyyppi TEXT,
huonekoodi TEXT REFERENCES Sali(huoneKoodi) NOT NULL
);

CREATE TABLE Varausaika (
varausID TEXT PRIMARY KEY,
huonekoodi TEXT REFERENCES Sali(huoneKoodi) NOT NULL,
klo TEXT CHECK (time('24:00') > time(substr(klo,0,5)) > time('00:00')),
pvm TEXT CHECK (date(pvm) > date('1900-01-01'))
);

CREATE TABLE Tenttivaraus (
varausid TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
Tnimi TEXT NOT NULL,
PRIMARY KEY (varausid),
FOREIGN KEY (varausid) REFERENCES Varausaika(varausID),
FOREIGN KEY (kurssikoodi, Tnimi) REFERENCES Tentti(kurssikoodi, Tnimi)
);

CREATE TABLE Harkkavaraus (
varausid TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
alku TEXT NOT NULL,
loppu TEXT NOT NULL,
harkkaid TEXT NOT NULL,
Hnimi TEXT NOT NULL,
PRIMARY KEY (varausid),
FOREIGN KEY (varausid) REFERENCES Varausaika(varausID),
FOREIGN KEY (kurssikoodi, alku, loppu, harkkaid, Hnimi) REFERENCES Harkkakerta(kurssikoodi, alku, loppu, harkkaid, Hnimi)
);

CREATE TABLE Luentovaraus (
varausid TEXT NOT NULL,
kurssikoodi TEXT NOT NULL,
alku TEXT NOT NULL,
loppu TEXT NOT NULL,
Lnimi TEXT NOT NULL,
PRIMARY KEY (varausid),
FOREIGN KEY (varausid) REFERENCES Varausaika(varausID),
FOREIGN KEY (kurssikoodi, alku, loppu, Lnimi) REFERENCES Luentokerta(kurssikoodi, alku, loppu, Lnimi)
);


CREATE INDEX VarausaikaIndex ON Varausaika(varausID);

CREATE INDEX VaraushuoneIndexX ON Varausaika(huonekoodi);

CREATE INDEX OpiskelijaIndex ON Opiskelija(opnro);

CREATE INDEX HarkkaaikaIndex ON Harkkakerta(alku, loppu, kurssikoodi, harkkaid, Hnimi);

CREATE INDEX LuentoaikaIndex ON Luentokerta(alku, loppu, kurssikoodi, Lnimi);

CREATE INDEX HarkkavarausIndex ON Harkkavaraus(varausid, kurssikoodi, alku, loppu, harkkaid, Hnimi);

CREATE INDEX LuentovarausIndex ON Luentovaraus(varausid, kurssikoodi, alku, loppu, Lnimi);

CREATE VIEW TulevatKurssikerrat AS
	SELECT koodi, nimi, op, alkupvm, loppupvm
	FROM Kurssi, Kurssikerta
	WHERE koodi=kurssikoodi AND
		(date(alkupvm)>= date('2018-09-01') AND date(loppupvm)<=date('2019-05-31'));

--TIETOKANNAN ESIMERKKIDATAN LUONTI

  
INSERT INTO Kurssi VALUES ( 'CS-U5555', 'Senttikurssi', 5);
INSERT INTO Kurssi VALUES ( 'AS-G0055', 'Markkakurssi', 10);
INSERT INTO Kurssi VALUES ( 'CS-I1235', 'Sinttikurssi', 3);
INSERT INTO Kurssi VALUES ('CS-A1150', 'Tietokannat', 5);
INSERT INTO Kurssi VALUES('CS-A1121', 'Ohjelmoinnin peruskurssi Y2', 5);
INSERT INTO Kurssi VALUES ('ELEC-A7100', 'C-ohjelmoinnin peruskurssi', 5);
INSERT INTO Kurssi VALUES ('CHEM-A1220', 'Orgaaninen kemia BioIT:lle', 5);
INSERT INTO Kurssi VALUES ('25C00200', 'Entrepreneruship and Innovation Management', 3);
INSERT INTO Kurssi VALUES ('MS-C2104', 'Introduction to Statistical Inference', 5);
INSERT INTO Kurssi VALUES ('MS-10101', 'Matikka 1', 5);
INSERT INTO Kurssi VALUES ('MS-20202', 'Matikka 2', 10);

INSERT INTO Kurssikerta VALUES ('MS-10101', '2010-01-01', '2010-02-01');
INSERT INTO Kurssikerta VALUES ('MS-20202', '2010-01-01', '2010-02-01');
INSERT INTO Kurssikerta VALUES ('CS-U5555', '2018-01-01', '2018-03-29');
INSERT INTO Kurssikerta VALUES ( 'AS-G0055', '2018-02-01', '2018-05-29');
INSERT INTO Kurssikerta VALUES ( 'CS-I1235', '2018-09-01', '2018-12-17');
INSERT INTO Kurssikerta VALUES('CS-A1150', '2018-02-01', '2018-05-22');
INSERT INTO Kurssikerta VALUES('CS-A1150', '2019-02-01', '2019-05-22');
INSERT INTO Kurssikerta VALUES('CS-A1121', '2018-01-06', '2018-05-01');
INSERT INTO Kurssikerta VALUES('MS-C2104', '2018-01-06', '2018-03-22');
INSERT INTO Kurssikerta VALUES('CHEM-A1220', '2018-02-16', '2018-03-24');
INSERT INTO Kurssikerta VALUES('ELEC-A7100', '2018-01-06', '2018-05-01');

INSERT INTO Opiskelija VALUES ('890476', 'Iso-Jarkko', '2005-06-13' ,'2017-07-15', 'Kauppakorkeakoulututkinto', 7);
INSERT INTO Opiskelija VALUES ('676767', 'Jantero', '1993-04-27', '2017-07-15', 'Kauppakorkeakoulututkinto', 7);
INSERT INTO Opiskelija VALUES ('000008', 'Tuomas Kupila', '1996-04-28', '2015-07-15', 'Elämänkoulu', 7);
INSERT INTO Opiskelija VALUES('123456', 'Teemu Teekkari', '1996-04-24', '2016-09-01', 'Sähkötekniikan kandidaattiohjelma', 7);
INSERT INTO Opiskelija VALUES('234567', 'Tiina Teekkari', '1998-11-04', '2018-09-01', 'Sähkötekniikan kandidaattiohjelma', 7);
INSERT INTO Opiskelija(opnro, nimi, saika, sisäänpvm, opohjelma) VALUES('526144', 'Tuomas Kupila', '1996-04-28', '2016-09-01', 'BIOIT');
INSERT INTO Opiskelija(opnro, nimi, saika, sisäänpvm, opohjelma) VALUES('089769', 'Teme Teekkars', '1990-01-01', '2005-09-01', 'TIK');
INSERT INTO Opiskelija(opnro, nimi, saika, sisäänpvm, opohjelma) VALUES('000007', 'Bond James', '1967-07-14', '2006-09-01', 'KIK');
INSERT INTO Opiskelija(opnro, nimi, saika, sisäänpvm, opohjelma) VALUES('784925', 'Mikko Mallikas', '2000-10-28', '2018-09-01', 'TUTA');
INSERT INTO Opiskelija VALUES('148062', 'Arto Ikiteekkari', '1900-01-02', '1920-09-14', 'CHEM', NULL);

INSERT INTO Rakennus VALUES('Otakaari 20', 'OK20');
INSERT INTO Rakennus VALUES('Maarintie 6', 'OIH');
INSERT INTO Rakennus VALUES('Tie 2', 'Talo');
INSERT INTO Rakennus VALUES ('Afrikantie 5', 'Villa Söder');
INSERT INTO Rakennus VALUES('Otakaari 1', 'Kandidaattikeskus');
INSERT INTO Rakennus VALUES('Maarintie 8', 'TUAS');
INSERT INTO Rakennus VALUES('Konemiehentie 2', 'Tietotekniikan talo');

INSERT INTO Sali VALUES ('AS33', 150, 100, 'Afrikantie 5');
INSERT INTO Sali VALUES ('R101', 400, 400, 'Tie 2');
INSERT INTO Sali VALUES('AALTO', '200', '100', 'Otakaari 1');
INSERT INTO Sali VALUES('B', '200', '100', 'Otakaari 1');
INSERT INTO Sali VALUES('AS1', '200', '100', 'Maarintie 8');
INSERT INTO Sali VALUES('T1', '200', '100', 'Konemiehentie 2');
INSERT INTO Sali VALUES('AS3', 150, 70, 'Maarintie 8');
INSERT INTO Sali VALUES('AS2', 100, 50, 'Maarintie 8');
INSERT INTO Sali VALUES('Iso puoli', 70, 1, 'Otakaari 20');

INSERT INTO Varuste VALUES(2001, 'Projektori', 'AS2');
INSERT INTO Varuste VALUES(2002, 'Projektori', 'AS3');
INSERT INTO Varuste VALUES(2003, 'Projektori', 'AS2');
INSERT INTO Varuste VALUES(2004, 'Kaiuttimet', 'AS2');

INSERT INTO Tentti VALUES ('CS-U5555', 'T1', '2018-03-29', '09:00:00-12:00:00');
INSERT INTO Tentti VALUES ('CS-U5555', 'T2', '2018-04-29', '09:00:00-12:00:00');
INSERT INTO Tentti VALUES ('CS-I1235', 'T1', '2018-12-15', '13:00:00-16:00:00');
INSERT INTO Tentti VALUES('CS-A1150', 'T01', '2018-05-22', '09:00-12:00');
INSERT INTO Tentti VALUES('CHEM-A1220', 'T02', '2018-05-21', '09:00-12:00');
INSERT INTO Tentti VALUES('MS-10101', 'T01', '2018-10-10', '09:00-12:30');
INSERT INTO Tentti VALUES ('MS-10101', 'T02', '2018-11-01', '12:00-14:00');

INSERT INTO Luentokerta VALUES ('2018-01-01', '2018-03-29', 'CS-U5555', 'L01', '2018-01-20', '08:15:00-10:00:00');
INSERT INTO Luentokerta VALUES ('2018-01-01', '2018-03-29', 'CS-U5555', 'L02', '2018-02-20','10:15:00-12:00:00');
INSERT INTO Luentokerta VALUES ('2018-09-01', '2018-12-17', 'CS-I1235', 'L01', '2018-10-01', '14:15:00-16:00:00');
INSERT INTO Luentokerta VALUES('2018-02-01', '2018-05-22', 'CS-A1150', 'L01', '2018-03-15', '10:15-11:45');
INSERT INTO Luentokerta VALUES('2018-01-06', '2018-05-01', 'ELEC-A7100', 'L01', '2018-04-06', '10:15-11:45');
INSERT INTO Luentokerta VALUES ('2010-01-01', '2010-02-01', 'MS-20202', 'L001', '2010-01-10', '10:00-12:00');
INSERT INTO Luentokerta VALUES ('2010-01-01', '2010-02-01', 'MS-10101', 'L001', '2010-01-10', '05:00-12:00');

INSERT INTO Harkkaryhmä VALUES ('2018-09-01', '2018-12-17', 'CS-I1235', 'H01',30);
INSERT INTO Harkkaryhmä VALUES ('2018-02-01', '2018-05-29', 'AS-G0055', 'H01', 20);
INSERT INTO Harkkaryhmä VALUES ('2018-02-01', '2018-05-29', 'AS-G0055', 'H02', 25);
INSERT INTO Harkkaryhmä VALUES('2018-02-01', '2018-05-22', 'CS-A1150', 'H01', 40);
INSERT INTO Harkkaryhmä VALUES('2018-01-06', '2018-05-01', 'ELEC-A7100', 'H04', 10);
INSERT INTO Harkkaryhmä VALUES('2010-01-01', '2010-02-01', 'MS-10101', 'H01', 20);
INSERT INTO Harkkaryhmä VALUES('2010-01-01', '2010-02-01', 'MS-10101', 'H02', 20);

INSERT INTO Harkkakerta VALUES ('2018-02-01', '2018-05-29', 'AS-G0055', 'H01', 'H011', '2018-02-19', '10:15:00-12:00:00');
INSERT INTO Harkkakerta VALUES ('2018-02-01', '2018-05-29', 'AS-G0055', 'H02', 'H021', '2018-02-27', '12:15:00-14:00:00');
INSERT INTO Harkkakerta VALUES('2010-01-01', '2010-02-01', 'MS-10101', 'H01', 'Harkka0001', '2010-01-03', '14:00-16:00');
INSERT INTO Harkkakerta VALUES('2010-01-01', '2010-02-01', 'MS-10101', 'H01', 'Harkka0002', '2010-01-07', '14:00-16:00');
INSERT INTO Harkkakerta VALUES ('2018-02-01', '2018-05-29', 'AS-G0055', 'H01', 'H012', '2018-03-15', '10:15-12:00');

INSERT INTO Harkkailmo VALUES('526144', 'MS-10101', '2010-01-01', '2010-02-01', 'H01');
INSERT INTO Harkkailmo VALUES('000007', 'MS-10101', '2010-01-01', '2010-02-01', 'H01');
INSERT INTO Harkkailmo VALUES('784925', 'MS-10101', '2010-01-01', '2010-02-01', 'H01');

INSERT INTO Tenttiilmo VALUES('526144', 'MS-10101', 'T01');
INSERT INTO Tenttiilmo VALUES('089769', 'MS-10101', 'T01');
INSERT INTO Tenttiilmo VALUES ('676767', 'CS-U5555', 'T1');
INSERT INTO Tenttiilmo VALUES ('000008', 'CS-U5555', 'T2');

INSERT INTO Varausaika VALUES ('1288','R101' ,'14:00:00-16:00:00', '2018-06-06');
INSERT INTO Varausaika VALUES ('1289', 'AS33', '09:00:00-12:00:00', '2018-02-02');
INSERT INTO Varausaika VALUES ('1279', 'R101', '12:00:00-14:00:00', '2018-03-17');
INSERT INTO Varausaika VALUES ('1277', 'R101', '08:00:00-10:00:00', '2018-03-17');
INSERT INTO Varausaika VALUES('1234','AALTO', '09:00-12:00', '2018-05-22');
INSERT INTO Varausaika VALUES('0001', 'AS2', '12:00-14:00', '2018-11-01');
INSERT INTO Varausaika VALUES('0002', 'AS2', '08:00-12:30', '2018-10-10');
INSERT INTO Varausaika VALUES('0003', 'Iso puoli', '10:00-12:00', '2018-01-10');
INSERT INTO Varausaika VALUES('ab', 'AS2', '12:00-14:00', '2018-03-10');
INSERT INTO Varausaika VALUES('ac', 'AS2', '10:00-12:00', '2018-03-10');
INSERT INTO Varausaika VALUES('af', 'AS2', '10:00-12:00', '2018-03-15');
INSERT INTO Varausaika VALUES ('varaus1', 'R101', '14:00-16:00', '2010-01-03');
INSERT INTO Varausaika VALUES ('varaus2', 'R101', '14:00-16:00', '2010-01-07');

INSERT INTO Tenttivaraus VALUES ('1288', 'CS-I1235', 'T1');
INSERT INTO Tenttivaraus VALUES ('1289', 'CS-U5555', 'T1');
INSERT INTO Tenttivaraus VALUES ('1234', 'CS-A1150', 'T01');
INSERT INTO Tenttivaraus VALUES ('0001', 'MS-10101', 'T02');
INSERT INTO Tenttivaraus VALUES ('0002', 'MS-10101', 'T01');
	
INSERT INTO Luentovaraus VALUES('0003', 'MS-20202', '2010-01-01', '2010-02-01', 'L001');

INSERT INTO Harkkavaraus VALUES ('ab', 'AS-G0055', '2018-02-01', '2018-05-29', 'H01', 'H011');
INSERT INTO Harkkavaraus VALUES ('ac', 'AS-G0055', '2018-02-01', '2018-05-29', 'H02', 'H021');
INSERT INTO Harkkavaraus VALUES ('af', 'AS-G0055', '2018-02-01', '2018-05-29', 'H01', 'H012');
INSERT INTO Harkkavaraus VALUES('varaus1', 'MS-10101', '2010-01-01', '2010-02-01', 'H01', 'Harkka0001');
INSERT INTO Harkkavaraus VALUES('varaus2', 'MS-10101', '2010-01-01', '2010-02-01', 'H01', 'Harkka0002');


--KÄYTTÖTAPAHTUMAT JA KYSELYT

--Etsitään opiskelijat, jotka on otettu sisään vuonna 2014 tai aikaisemmin ja tulostaa ne

SELECT *
FROM Opiskelija
WHERE date(sisäänpvm) < date('2015-01-01');

--Opettaja tarkistaa milloin sali on vapaana/varattu tiettynä päivämääränä

SELECT Varausaika.varausid, Varausaika.klo, Varausaika.pvm
FROM Varausaika, Sali
WHERE Varausaika.huonekoodi = Sali.huonekoodi AND Varausaika.pvm = '2018-03-17'
ORDER BY klo;


--Opettaja tarkistaa mistä rakennuksen huoneesta löytyy tarvittavat varusteet esim. Projektori

SELECT DISTINCT Sali.huonekoodi
FROM Sali, Varuste, Rakennus
WHERE Sali.osoite='Maarintie 8' AND Sali.huonekoodi=Varuste.huonekoodi AND
	Varuste.tyyppi='Projektori';


--Katsotaan mitä varusteita halutussa salissa on ja tulsotaa ne

SELECT *
FROM Varuste
WHERE huonekoodi = 'AS2';


--Etsitään mitä tenttejä halutulla kurssilla on halutulla aikavälillä

SELECT DISTINCT kurssikoodi, Tnimi
FROM Tentti
Where kurssikoodi = 'CS-U5555' AND pvm > '2018-01-01' AND pvm < '2018-04-15';


--Selvitetään mitä kurssikertoja tietystä kurssista menee ja ilmoitetaan 
--opiskelija sinne ilmoamalla se harkkaryhmään

SELECT kurssikoodi, alkupvm, loppupvm
FROM Kurssikerta
WHERE kurssikoodi = 'CS-A1150';

INSERT INTO Harkkailmo
VALUES('000007', 'CS-A1150', '2018-02-01', '2018-05-22', 'H01');


--Selvitetään mitä luentoja tiettyyn kurssikertaan liittyy

SELECT DISTINCT Lnimi, pvm, klo
FROM Luentokerta, Kurssikerta, Kurssi
WHERE Luentokerta.alku='2018-02-01' AND Luentokerta.loppu='2018-05-22'
AND Luentokerta.kurssikoodi='CS-A1150';


--Selvitetään mitä harkkaryhmiä tiettyyn kurssikertaan liittyy ja tulostetaan ne

SELECT DISTINCT Harkkaryhmä.kurssikoodi, HarkkaID
FROM Harkkaryhmä
WHERE Harkkaryhmä.alku='2018-02-01' AND Harkkaryhmä.loppu='2018-05-29'
AND Harkkaryhmä.kurssikoodi='AS-G0055';



--Selvitetään missä ja milloin haluttu harkkaryhmä kokoontuu

SELECT DISTINCT Harkkakerta.harkkaid,Harkkakerta.Hnimi, Varausaika.huonekoodi, Varausaika.pvm, Varausaika.klo
FROM Harkkakerta, Harkkavaraus, Varausaika
WHERE Harkkakerta.alku = '2018-02-01' AND Harkkakerta.loppu = '2018-05-29' AND Harkkakerta.kurssikoodi = 'AS-G0055' AND Harkkakerta.harkkaid = 'H01' AND Harkkakerta.Hnimi = Harkkavaraus.Hnimi AND Harkkavaraus.varausid = Varausaika.varausID;


--Etsitään kaikki haluttuun tenttiin ilmoittautuneet opiskelijat

SELECT Opiskelija.opnro, nimi, Tnimi, Kurssikoodi
FROM Opiskelija, Tenttiilmo
WHERE Opiskelija.opnro = Tenttiilmo.opnro AND Kurssikoodi = 'CS-U5555' AND Tnimi = 'T2';


--Haetaan yksitellen onko kyseisenä aikana kyseisessä paikassa varauksia (Huom! Nämä 
--voi yhdistää niin, ettei ota huomioon, esimerkiksi käyttöliittymässä, tyhjiä tulostuksia)

SELECT DISTINCT Tnimi
FROM Varausaika, Tenttivaraus
WHERE Varausaika.huonekoodi = 'AS2' AND Varausaika.klo = '12:00-14:00' AND Varausaika.pvm = '2018-11-01' AND Varausaika.varausID = Tenttivaraus.varausid;

SELECT DISTINCT Lnimi
FROM Varausaika, Luentovaraus
WHERE Varausaika.huonekoodi = 'AS2' AND Varausaika.klo = '12:00-14:00' AND Varausaika.pvm = '2018-11-01' AND Varausaika.varausID = Luentovaraus.varausid;

SELECT DISTINCT Hnimi
FROM Varausaika, Harkkavaraus
WHERE Varausaika.huonekoodi = 'AS2' AND Varausaika.klo = '12:00-14:00' AND Varausaika.pvm = '2018-11-01' AND Varausaika.varausID = Harkkavaraus.varausid;


--Etsitään sali, jossa on vähintään haluttu määrä paikkoja ja joka on vapaa haluttuna aikana.

SELECT DISTINCT huoneKoodi
FROM Sali
WHERE huonekoodi !=
(SELECT DISTINCT Sali.huonekoodi
FROM Varausaika, Sali
WHERE (Varausaika.huonekoodi = Sali.huoneKoodi AND Varausaika.klo = '12:00-14:00' AND Varausaika.pvm = '2018-11-01'))
AND Sali.istumapaikat > 150;


--Etsiä halutulta kurssilta ne harjoitusryhmät, joissa on vielä tilaa.

SELECT DISTINCT Harkkaryhmä.harkkaID
FROM Harkkaryhmä
WHERE Harkkaryhmä.kurssikoodi = 'MS-10101'AND Harkkaryhmä.alku = '2010-01-01' AND Harkkaryhmä.loppu = '2010-02-01' AND Harkkaryhmä.harkkaID NOT IN
(SELECT Harkkailmo.harkkaid
FROM Harkkailmo,Harkkaryhmä
WHERE Harkkailmo.harkkaid = Harkkaryhmä.harkkaID
GROUP BY Harkkailmo.harkkaid
HAVING COUNT(DISTINCT opnro) > Harkkaryhmä.maxosallistujat);


-- Siirretään varuste toiseen saliin

UPDATE Varuste
SET huonekoodi = 'R101'
WHERE tuotenro = 2001;