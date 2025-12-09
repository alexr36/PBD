/*
 * *****************************************************************************
 * @file           : test_db_extension.sql
 * @author         : File provided by the course instructor.
 * @brief          : This file contains all necessary operations to extend 
                     current database with a new table filled with data.
 * *****************************************************************************
 */

-- Ustawienie formatu daty, aby pasował do danych (YYYY-MM-DD)
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

-- Usunięcie tabeli, jeśli już istnieje
DROP TABLE Historia_Incydentow CASCADE CONSTRAINTS;

-- Tworzenie tabeli
CREATE TABLE Historia_Incydentow (
    id_incydentu NUMBER(5) CONSTRAINT hi_pk PRIMARY KEY,
    pseudo VARCHAR2(15) CONSTRAINT hi_ps_fk REFERENCES Kocury(pseudo),
    imie_wroga VARCHAR2(15) CONSTRAINT hi_iw_fk REFERENCES Wrogowie(imie_wroga),
    data_incydentu DATE CONSTRAINT hi_data_nn NOT NULL,
    miejsce VARCHAR2(15), -- Teren z tabeli Bandy
    straty_myszy NUMBER(3),
    poziom_agresji NUMBER(2) CONSTRAINT hi_agresja_ch CHECK (poziom_agresji BETWEEN 1 AND 10),
    wynik VARCHAR2(10) CONSTRAINT hi_wynik_ch CHECK (wynik IN ('KOT', 'WROG', 'REMIS')),
    czas_trwania_min NUMBER(3),
    liczba_swiadkow NUMBER(1) CONSTRAINT hi_swiadkowie_ch CHECK (liczba_swiadkow BETWEEN 0 AND 5),
    rekonwalescencja VARCHAR2(10) CONSTRAINT hi_rekonw_ch CHECK (rekonwalescencja IN ('BRAK', 'SZYBKA', 'DLUGA'))
);

-- Wstawianie danych
INSERT INTO Historia_Incydentow VALUES (1, 'TYGRYS', 'KAZIO', '2002-03-15', 'POLE', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (2, 'TYGRYS', 'KAZIO', '2002-04-20', 'SAD', 2, 5, 'REMIS', 15, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (3, 'TYGRYS', 'KAZIO', '2002-06-01', 'GORKA', 0, 8, 'KOT', 20, 3, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (4, 'TYGRYS', 'KAZIO', '2002-08-12', 'ZAGRODA', 4, 9, 'WROG', 45, 1, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (5, 'TYGRYS', 'KAZIO', '2002-10-05', 'POLE', 1, 3, 'REMIS', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (6, 'TYGRYS', 'KAZIO', '2002-12-24', 'SAD', 0, 6, 'KOT', 25, 4, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (7, 'TYGRYS', 'KAZIO', '2003-02-14', 'GORKA', 3, 7, 'WROG', 30, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (8, 'TYGRYS', 'KAZIO', '2003-04-10', 'POLE', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (9, 'TYGRYS', 'KAZIO', '2003-06-15', 'ZAGRODA', 5, 8, 'REMIS', 35, 3, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (10, 'TYGRYS', 'KAZIO', '2003-08-20', 'SAD', 0, 4, 'KOT', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (11, 'TYGRYS', 'KAZIO', '2003-10-11', 'GORKA', 2, 9, 'WROG', 50, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (12, 'TYGRYS', 'KAZIO', '2003-12-05', 'POLE', 0, 1, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (13, 'TYGRYS', 'KAZIO', '2004-02-02', 'SAD', 4, 6, 'WROG', 25, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (14, 'TYGRYS', 'KAZIO', '2004-05-15', 'ZAGRODA', 1, 5, 'REMIS', 20, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (15, 'TYGRYS', 'KAZIO', '2004-08-01', 'GORKA', 0, 3, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (16, 'TYGRYS', 'KAZIO', '2004-10-13', 'POLE', 6, 10, 'WROG', 60, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (17, 'BOLEK', 'KAZIO', '2002-06-10', 'SAD', 0, 2, 'KOT', 8, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (18, 'BOLEK', 'KAZIO', '2002-09-15', 'POLE', 3, 5, 'WROG', 20, 0, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (19, 'BOLEK', 'KAZIO', '2002-11-20', 'GORKA', 1, 4, 'REMIS', 15, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (20, 'BOLEK', 'KAZIO', '2003-01-10', 'ZAGRODA', 0, 1, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (21, 'BOLEK', 'KAZIO', '2003-03-25', 'SAD', 4, 7, 'WROG', 35, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (22, 'BOLEK', 'KAZIO', '2003-06-05', 'POLE', 0, 3, 'KOT', 12, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (23, 'BOLEK', 'KAZIO', '2003-08-15', 'GORKA', 2, 6, 'REMIS', 25, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (24, 'BOLEK', 'KAZIO', '2003-10-30', 'ZAGRODA', 5, 8, 'WROG', 40, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (25, 'BOLEK', 'KAZIO', '2004-01-15', 'SAD', 0, 2, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (26, 'BOLEK', 'KAZIO', '2004-04-20', 'POLE', 3, 5, 'REMIS', 18, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (27, 'BOLEK', 'KAZIO', '2004-07-05', 'GORKA', 1, 4, 'KOT', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (28, 'BOLEK', 'KAZIO', '2004-09-12', 'ZAGRODA', 6, 9, 'WROG', 50, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (29, 'BOLEK', 'KAZIO', '2004-12-01', 'SAD', 0, 3, 'REMIS', 12, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (30, 'BOLEK', 'KAZIO', '2005-03-29', 'POLE', 2, 6, 'WROG', 30, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (31, 'TYGRYS', 'DZIKI BILL', '2002-05-10', 'GORKA', 0, 4, 'KOT', 20, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (32, 'TYGRYS', 'DZIKI BILL', '2002-11-05', 'ZAGRODA', 5, 8, 'WROG', 45, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (33, 'TYGRYS', 'DZIKI BILL', '2003-05-20', 'POLE', 2, 6, 'REMIS', 30, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (34, 'TYGRYS', 'DZIKI BILL', '2003-12-15', 'SAD', 0, 3, 'KOT', 15, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (35, 'TYGRYS', 'DZIKI BILL', '2004-06-10', 'GORKA', 4, 9, 'WROG', 55, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (36, 'TYGRYS', 'DZIKI BILL', '2004-11-25', 'ZAGRODA', 1, 5, 'KOT', 25, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (37, 'TYGRYS', 'DZIKI BILL', '2005-04-15', 'POLE', 0, 2, 'KOT', 10, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (38, 'TYGRYS', 'DZIKI BILL', '2005-10-05', 'SAD', 3, 7, 'WROG', 40, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (39, 'TYGRYS', 'DZIKI BILL', '2006-03-20', 'GORKA', 2, 6, 'REMIS', 35, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (40, 'TYGRYS', 'DZIKI BILL', '2006-09-10', 'ZAGRODA', 0, 4, 'KOT', 18, 0, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (41, 'TYGRYS', 'DZIKI BILL', '2007-02-15', 'POLE', 5, 8, 'WROG', 50, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (42, 'TYGRYS', 'DZIKI BILL', '2007-06-12', 'SAD', 0, 3, 'KOT', 12, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (43, 'BOLEK', 'DZIKI BILL', '2002-07-20', 'POLE', 2, 5, 'REMIS', 20, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (44, 'BOLEK', 'DZIKI BILL', '2003-02-10', 'SAD', 0, 2, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (45, 'BOLEK', 'DZIKI BILL', '2003-09-05', 'GORKA', 4, 7, 'WROG', 35, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (46, 'BOLEK', 'DZIKI BILL', '2004-03-15', 'ZAGRODA', 1, 4, 'KOT', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (47, 'BOLEK', 'DZIKI BILL', '2004-10-20', 'POLE', 3, 6, 'REMIS', 25, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (48, 'BOLEK', 'DZIKI BILL', '2005-06-12', 'SAD', 5, 8, 'WROG', 45, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (49, 'BOLEK', 'DZIKI BILL', '2006-01-05', 'GORKA', 0, 3, 'KOT', 12, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (50, 'BOLEK', 'DZIKI BILL', '2006-08-20', 'ZAGRODA', 2, 5, 'KOT', 18, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (51, 'BOLEK', 'DZIKI BILL', '2007-04-10', 'POLE', 4, 9, 'WROG', 50, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (52, 'BOLEK', 'DZIKI BILL', '2007-11-10', 'SAD', 1, 4, 'REMIS', 20, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (53, 'ZOMBI', 'SWAWOLNY DYZIO', '2004-04-01', 'SAD', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (54, 'ZOMBI', 'SWAWOLNY DYZIO', '2004-05-15', 'SAD', 1, 4, 'KOT', 10, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (55, 'ZOMBI', 'SWAWOLNY DYZIO', '2004-07-20', 'SAD', 3, 6, 'WROG', 25, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (56, 'ZOMBI', 'SWAWOLNY DYZIO', '2004-09-05', 'SAD', 0, 1, 'REMIS', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (57, 'ZOMBI', 'SWAWOLNY DYZIO', '2004-10-12', 'SAD', 2, 5, 'KOT', 15, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (58, 'ZOMBI', 'SWAWOLNY DYZIO', '2004-11-25', 'SAD', 4, 7, 'WROG', 30, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (59, 'ZOMBI', 'SWAWOLNY DYZIO', '2005-01-10', 'SAD', 0, 3, 'KOT', 12, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (60, 'ZOMBI', 'SWAWOLNY DYZIO', '2005-02-15', 'SAD', 1, 4, 'REMIS', 18, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (61, 'ZOMBI', 'SWAWOLNY DYZIO', '2005-03-07', 'SAD', 5, 8, 'WROG', 40, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (62, 'SZYBKA', 'GLUPIA ZOSKA', '2006-07-25', 'POLE', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (63, 'SZYBKA', 'GLUPIA ZOSKA', '2006-08-05', 'POLE', 1, 4, 'REMIS', 10, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (64, 'SZYBKA', 'GLUPIA ZOSKA', '2006-08-15', 'POLE', 0, 1, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (65, 'SZYBKA', 'GLUPIA ZOSKA', '2006-08-30', 'POLE', 2, 5, 'KOT', 15, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (66, 'SZYBKA', 'GLUPIA ZOSKA', '2006-09-12', 'POLE', 3, 7, 'WROG', 25, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (67, 'MALA', 'CHYTRUSEK', '2006-09-25', 'GORKA', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (68, 'MALA', 'CHYTRUSEK', '2006-10-15', 'SAD', 1, 3, 'KOT', 10, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (69, 'MALA', 'CHYTRUSEK', '2006-11-20', 'POLE', 2, 5, 'REMIS', 20, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (70, 'MALA', 'CHYTRUSEK', '2007-01-10', 'ZAGRODA', 4, 6, 'WROG', 30, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (71, 'MALA', 'CHYTRUSEK', '2007-02-15', 'GORKA', 0, 4, 'KOT', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (72, 'MALA', 'CHYTRUSEK', '2007-03-07', 'SAD', 1, 5, 'REMIS', 18, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (73, 'LASKA', 'DZIKI BILL', '2008-02-10', 'POLE', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (74, 'LASKA', 'DZIKI BILL', '2008-03-25', 'POLE', 3, 6, 'WROG', 25, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (75, 'LASKA', 'DZIKI BILL', '2008-05-15', 'POLE', 1, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (76, 'LASKA', 'DZIKI BILL', '2008-07-01', 'POLE', 0, 3, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (77, 'LASKA', 'DZIKI BILL', '2008-08-20', 'POLE', 4, 7, 'WROG', 35, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (78, 'LASKA', 'DZIKI BILL', '2008-10-05', 'POLE', 2, 5, 'KOT', 20, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (79, 'LASKA', 'DZIKI BILL', '2008-11-15', 'POLE', 0, 4, 'REMIS', 18, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (80, 'LASKA', 'DZIKI BILL', '2008-12-12', 'POLE', 5, 8, 'WROG', 45, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (81, 'LASKA', 'KAZIO', '2008-02-20', 'POLE', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (82, 'LASKA', 'KAZIO', '2008-04-10', 'POLE', 1, 5, 'KOT', 15, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (83, 'LASKA', 'KAZIO', '2008-06-05', 'POLE', 2, 6, 'WROG', 25, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (84, 'LASKA', 'KAZIO', '2008-08-15', 'POLE', 0, 3, 'REMIS', 12, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (85, 'LASKA', 'KAZIO', '2008-10-25', 'POLE', 3, 7, 'WROG', 30, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (86, 'LASKA', 'KAZIO', '2008-12-05', 'POLE', 0, 4, 'KOT', 18, 0, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (87, 'LASKA', 'KAZIO', '2009-01-07', 'POLE', 4, 8, 'WROG', 40, 5, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (88, 'DAMA', 'KAZIO', '2008-11-05', 'GORKA', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (89, 'DAMA', 'KAZIO', '2008-11-20', 'GORKA', 1, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (90, 'DAMA', 'KAZIO', '2008-12-10', 'GORKA', 0, 3, 'KOT', 10, 2, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (91, 'DAMA', 'KAZIO', '2009-01-15', 'GORKA', 2, 6, 'WROG', 25, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (92, 'DAMA', 'KAZIO', '2009-02-07', 'GORKA', 1, 5, 'KOT', 18, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (93, 'MAN', 'REKSIO', '2008-07-20', 'GORKA', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (94, 'MAN', 'REKSIO', '2008-09-05', 'GORKA', 1, 4, 'REMIS', 12, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (95, 'MAN', 'REKSIO', '2008-10-15', 'GORKA', 2, 6, 'WROG', 25, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (96, 'MAN', 'REKSIO', '2008-12-20', 'GORKA', 0, 3, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (97, 'MAN', 'REKSIO', '2009-02-10', 'GORKA', 3, 7, 'WROG', 35, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (98, 'MAN', 'REKSIO', '2009-04-14', 'GORKA', 0, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (99, 'LYSY', 'BETHOVEN', '2006-09-01', 'POLE', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (100, 'LYSY', 'BETHOVEN', '2007-01-15', 'POLE', 1, 4, 'KOT', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (101, 'LYSY', 'BETHOVEN', '2007-05-20', 'POLE', 0, 3, 'REMIS', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (102, 'LYSY', 'BETHOVEN', '2007-10-05', 'POLE', 2, 5, 'WROG', 20, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (103, 'LYSY', 'BETHOVEN', '2008-03-10', 'POLE', 0, 4, 'KOT', 12, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (104, 'LYSY', 'BETHOVEN', '2008-08-15', 'POLE', 1, 6, 'WROG', 30, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (105, 'LYSY', 'BETHOVEN', '2009-01-20', 'POLE', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (106, 'LYSY', 'BETHOVEN', '2009-05-11', 'POLE', 3, 7, 'WROG', 35, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (107, 'RURA', 'DZIKI BILL', '2009-09-02', 'POLE', 0, 3, 'REMIS', 10, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (108, 'RURA', 'DZIKI BILL', '2009-09-03', 'POLE', 2, 6, 'WROG', 25, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (109, 'PLACEK', 'BAZYLI', '2008-12-15', 'POLE', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (110, 'PLACEK', 'BAZYLI', '2009-03-20', 'POLE', 1, 4, 'KOT', 10, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (111, 'PLACEK', 'BAZYLI', '2009-08-05', 'POLE', 0, 3, 'REMIS', 12, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (112, 'PLACEK', 'BAZYLI', '2010-01-10', 'POLE', 2, 5, 'WROG', 20, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (113, 'PLACEK', 'BAZYLI', '2010-07-12', 'POLE', 1, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (114, 'PUSZYSTA', 'SMUKLA', '2010-11-19', 'SAD', 0, 2, 'WROG', 5, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (115, 'KURKA', 'BUREK', '2008-03-10', 'SAD', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (116, 'KURKA', 'BUREK', '2008-09-15', 'SAD', 1, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (117, 'KURKA', 'BUREK', '2009-04-20', 'SAD', 0, 3, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (118, 'KURKA', 'BUREK', '2009-11-05', 'SAD', 2, 5, 'WROG', 25, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (119, 'KURKA', 'BUREK', '2010-12-14', 'SAD', 3, 6, 'WROG', 30, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (120, 'MALY', 'CHYTRUSEK', '2011-06-01', 'GORKA', 0, 3, 'REMIS', 10, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (121, 'MALY', 'CHYTRUSEK', '2011-07-13', 'GORKA', 1, 5, 'WROG', 20, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (122, 'UCHO', 'SWAWOLNY DYZIO', '2011-02-15', 'GORKA', 0, 2, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (123, 'UCHO', 'SWAWOLNY DYZIO', '2011-04-20', 'GORKA', 1, 4, 'KOT', 12, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (124, 'UCHO', 'SWAWOLNY DYZIO', '2011-07-14', 'GORKA', 2, 6, 'WROG', 25, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (125, 'TYGRYS', 'KAZIO', '2002-05-01', 'POLE', 0, 1, 'KOT', 5, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (126, 'TYGRYS', 'KAZIO', '2002-07-15', 'SAD', 3, 6, 'WROG', 30, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (127, 'TYGRYS', 'KAZIO', '2002-11-10', 'ZAGRODA', 1, 4, 'REMIS', 15, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (128, 'TYGRYS', 'KAZIO', '2003-03-05', 'GORKA', 0, 3, 'KOT', 10, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (129, 'TYGRYS', 'KAZIO', '2003-05-25', 'POLE', 2, 5, 'REMIS', 20, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (130, 'TYGRYS', 'KAZIO', '2003-09-10', 'SAD', 4, 8, 'WROG', 40, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (131, 'TYGRYS', 'KAZIO', '2004-01-05', 'ZAGRODA', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (132, 'TYGRYS', 'KAZIO', '2004-03-20', 'GORKA', 1, 4, 'KOT', 12, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (133, 'TYGRYS', 'DZIKI BILL', '2002-08-10', 'SAD', 0, 3, 'REMIS', 15, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (134, 'TYGRYS', 'DZIKI BILL', '2003-01-20', 'GORKA', 3, 7, 'WROG', 35, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (135, 'TYGRYS', 'DZIKI BILL', '2003-07-15', 'POLE', 1, 4, 'KOT', 20, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (136, 'TYGRYS', 'DZIKI BILL', '2004-04-05', 'ZAGRODA', 0, 2, 'KOT', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (137, 'TYGRYS', 'DZIKI BILL', '2004-09-15', 'SAD', 4, 8, 'WROG', 45, 4, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (138, 'TYGRYS', 'DZIKI BILL', '2005-01-25', 'GORKA', 2, 5, 'REMIS', 25, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (139, 'TYGRYS', 'DZIKI BILL', '2005-07-10', 'POLE', 0, 3, 'KOT', 12, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (140, 'TYGRYS', 'DZIKI BILL', '2006-05-05', 'ZAGRODA', 3, 6, 'WROG', 30, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (141, 'BOLEK', 'KAZIO', '2002-07-25', 'POLE', 1, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (142, 'BOLEK', 'KAZIO', '2002-10-10', 'ZAGRODA', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (143, 'BOLEK', 'KAZIO', '2003-02-15', 'SAD', 2, 5, 'WROG', 20, 2, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (144, 'BOLEK', 'KAZIO', '2003-05-20', 'GORKA', 1, 4, 'KOT', 12, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (145, 'BOLEK', 'KAZIO', '2003-09-10', 'POLE', 3, 7, 'WROG', 35, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (146, 'BOLEK', 'KAZIO', '2004-02-05', 'ZAGRODA', 0, 3, 'REMIS', 10, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (147, 'BOLEK', 'KAZIO', '2004-06-15', 'SAD', 2, 5, 'KOT', 18, 2, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (148, 'BOLEK', 'DZIKI BILL', '2002-12-05', 'GORKA', 0, 2, 'KOT', 8, 0, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (149, 'BOLEK', 'DZIKI BILL', '2003-06-20', 'POLE', 1, 4, 'REMIS', 15, 1, 'SZYBKA');
INSERT INTO Historia_Incydentow VALUES (150, 'BOLEK', 'DZIKI BILL', '2004-01-10', 'ZAGRODA', 3, 7, 'WROG', 30, 3, 'DLUGA');
INSERT INTO Historia_Incydentow VALUES (151, 'BOLEK', 'DZIKI BILL', '2004-08-05', 'SAD', 0, 3, 'KOT', 12, 1, 'BRAK');
INSERT INTO Historia_Incydentow VALUES (152, 'BOLEK', 'DZIKI BILL', '2005-02-25', 'GORKA', 2, 5, 'KOT', 20, 2, 'SZYBKA');

COMMIT;