/*
 * ******************************************************************************
 * @file           : oracle_triggers_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL triggers from List 04.
 * ******************************************************************************
 */

-- Run to make output visible
SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- TASK 3
--------------------------------------------------------------------------------
-- Definicja
CREATE OR REPLACE TRIGGER trg_autonum_bandy
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
    SELECT
        MAX(nr_bandy) + 1
    INTO
        :NEW.nr_bandy
    FROM Bandy;
END trg_autonum_bandy;
/

-- Wywołanie
INSERT INTO Bandy VALUES (0, 'Nowa banda', 'Wybrzeze', 'MALA');

SELECT * FROM Bandy;

ROLLBACK;

DROP TRIGGER trg_autonum_bandy;

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
-- Definicja relacji
CREATE TABLE Przekroczenia_przydzialow (
    kto      VARCHAR2(15),
    kiedy    DATE,
    komu     VARCHAR(15),
    operacja VARCHAR(6)
);

-- Definicja wyzwalacza
CREATE OR REPLACE TRIGGER trg_guard_przydzialy
BEFORE INSERT OR UPDATE ON Kocury
FOR EACH ROW
DECLARE
    v_funkcja_min Funkcje.min_myszy%TYPE;
    v_funkcja_max Funkcje.max_myszy%TYPE;
    v_operacja    VARCHAR(6) := 'INSERT';
BEGIN
    IF UPDATING THEN
        v_operacja := 'UPDATE';
    END IF;

    SELECT
        min_myszy,
        max_myszy
    INTO
        v_funkcja_min,
        v_funkcja_max
    FROM Funkcje
    WHERE
        funkcja = :NEW.funkcja;

    IF :NEW.przydzial_myszy NOT BETWEEN v_funkcja_min AND v_funkcja_max THEN
        INSERT INTO Przekroczenia_przydzialow VALUES (SYS.LOGIN_USER, SYSDATE, :NEW.pseudo, v_operacja);
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
    END IF;
END trg_guard_przydzialy;
/ 

-- Wywołanie
UPDATE Kocury
SET przydzial_myszy = 600
WHERE 
    pseudo IN ('RAFA', 'ZERO');

SELECT
    kto,
    TO_CHAR(kiedy, 'YYYY-MM-DD') "KIEDY",
    komu,
    operacja
FROM Przekroczenia_przydzialow;

SELECT
    pseudo,
    przydzial_myszy
FROM Kocury
WHERE
    pseudo IN ('RAFA', 'ZERO');

DROP TABLE Przekroczenia_przydzialow;

ROLLBACK;

DROP TRIGGER trg_guard_przydzialy;

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
-- a)
-- Definicja pakietu
CREATE OR REPLACE PACKAGE pkg_wirus
AS
    g_mutex             BOOLEAN   := FALSE;
    g_delta_przydzialow NUMBER(3);
END pkg_wirus;
/

-- Definicja wyzwalaczy
CREATE OR REPLACE TRIGGER trg_przed
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
WHEN (OLD.funkcja = 'MILUSIA')
BEGIN
    -- Zapamietaj delte przydzialow
    IF pkg_wirus.g_delta_przydzialow IS NULL THEN
        pkg_wirus.g_delta_przydzialow := :NEW.przydzial_myszy - :OLD.przydzial_myszy;
    END IF;

    -- Jesli obnizka, rzuc wyjatek
    IF pkg_wirus.g_delta_przydzialow < 0 THEN
        pkg_wirus.g_delta_przydzialow := NULL;
        RAISE_APPLICATION_ERROR(-20001, 'Nie mozna zmniejszyc przydzialu myszy.');
    END IF;
END trg_przed;
/

CREATE OR REPLACE TRIGGER trg_po
AFTER UPDATE OF przydzial_myszy ON Kocury
DECLARE
    v_przydzial_tygrys  Kocury.przydzial_myszy%TYPE;
    v_10_procent_tygrys NUMBER(3);
BEGIN
    IF pkg_wirus.g_delta_przydzialow IS NULL OR pkg_wirus.g_delta_przydzialow = 0 OR pkg_wirus.g_mutex THEN
        RETURN;
    END IF;

    -- Blokada na update
    pkg_wirus.g_mutex := TRUE;

    -- Wez aktualny przydzial tygrysa i jego 10%
    SELECT
        przydzial_myszy,
        ROUND(0.1 * przydzial_myszy)
    INTO
        v_przydzial_tygrys,
        v_10_procent_tygrys
    FROM Kocury
    WHERE
        pseudo = 'TYGRYS';

    IF pkg_wirus.g_delta_przydzialow < v_10_procent_tygrys THEN
        -- Zwieksz przydzialy dla milus
        UPDATE Kocury
        SET 
            przydzial_myszy = przydzial_myszy + v_10_procent_tygrys - pkg_wirus.g_delta_przydzialow,
            myszy_extra     = NVL(myszy_extra, 0) + 5
        WHERE
            funkcja = 'MILUSIA';

        -- Zabierz Tygrysowi
        UPDATE Kocury
        SET przydzial_myszy = przydzial_myszy - v_10_procent_tygrys
        WHERE
            pseudo = 'TYGRYS';
    ELSE
        -- Dodaj extra Tygrysowi
        UPDATE Kocury
        SET myszy_extra = NVL(myszy_extra, 0) + 5
        WHERE
            pseudo = 'TYGRYS';
    END IF;

    pkg_wirus.g_delta_przydzialow := NULL;
    pkg_wirus.g_mutex             := FALSE; 
EXCEPTION
    WHEN OTHERS THEN
        pkg_wirus.g_delta_przydzialow := NULL;
        pkg_wirus.g_mutex             := FALSE;
        RAISE;  
END trg_po;
/

-- Wywołanie
SELECT
    pseudo,
    funkcja,
    przydzial_myszy,
    NVL(myszy_extra, 0) "EXTRA"
FROM Kocury
WHERE
    funkcja = 'MILUSIA'
    OR
    pseudo = 'TYGRYS'
ORDER BY 
    funkcja;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 4
WHERE
    funkcja = 'MILUSIA';

SELECT
    pseudo,
    funkcja,
    przydzial_myszy,
    NVL(myszy_extra, 0) "EXTRA"
FROM Kocury
WHERE
    funkcja = 'MILUSIA'
    OR
    pseudo = 'TYGRYS'
ORDER BY 
    funkcja;

ROLLBACK;

DROP PACKAGE pkg_wirus;
DROP TRIGGER trg_przed;
DROP TRIGGER trg_po;

-- Explicit rollback
UPDATE Kocury SET myszy_extra = 47, przydzial_myszy = 25  WHERE pseudo = 'LOLA';
UPDATE Kocury SET myszy_extra = 35, przydzial_myszy = 20  WHERE pseudo = 'PUSZYSTA';
UPDATE Kocury SET myszy_extra = 42, przydzial_myszy = 22  WHERE pseudo = 'MALA';
UPDATE Kocury SET myszy_extra = 28, przydzial_myszy = 24  WHERE pseudo = 'LASKA';
UPDATE Kocury SET myszy_extra = 33, przydzial_myszy = 103 WHERE pseudo = 'TYGRYS';

-- b)
--Definicja wyzwalacza
CREATE OR REPLACE TRIGGER trg_wirus
FOR UPDATE OF przydzial_myszy ON Kocury
COMPOUND TRIGGER
    v_delta_przydzialow Kocury.przydzial_myszy%TYPE;
    v_przydzial_tygrys  Kocury.przydzial_myszy%TYPE;
    v_10_procent_tygrys Kocury.przydzial_myszy%TYPE;
    v_za_malo           BOOLEAN := FALSE;

    BEFORE STATEMENT IS
    BEGIN
        -- Oblicz przdzial Tygrysa i jego 10%
        SELECT
            przydzial_myszy,
            ROUND(0.1 * przydzial_myszy)
        INTO
            v_przydzial_tygrys,
            v_10_procent_tygrys
        FROM Kocury
        WHERE
            pseudo = 'TYGRYS';
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        -- Zapamietaj delte przydzialow dla milus
        IF :OLD.funkcja = 'MILUSIA' AND v_delta_przydzialow IS NULL THEN
            v_delta_przydzialow := :NEW.przydzial_myszy - :OLD.przydzial_myszy;

            IF v_delta_przydzialow < 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Nie mozna zmniejszyc przydzialu myszy.');
            END IF;

            IF v_delta_przydzialow < v_10_procent_tygrys THEN
                -- Zaktualizuj bonusowe przydzialy dla milus
                v_za_malo            := TRUE;
                :NEW.przydzial_myszy := :OLD.przydzial_myszy + v_10_procent_tygrys;
                :NEW.myszy_extra     := NVL(:NEW.myszy_extra, 0) + 5;
            END IF;
        END IF;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        IF v_delta_przydzialow != 0 THEN
            IF v_za_malo THEN            
                -- Zabierz Tygrysowi
                UPDATE Kocury
                SET przydzial_myszy = przydzial_myszy - v_10_procent_tygrys
                WHERE
                    pseudo = 'TYGRYS';
            ELSE
                -- Dodaj extra Tygrysowi
                UPDATE Kocury
                SET myszy_extra = NVL(myszy_extra, 0) + 5
                WHERE
                    pseudo = 'TYGRYS';
            END IF;
        END IF;
    END AFTER STATEMENT;
END trg_wirus;
/

-- Wywołanie
SELECT
    pseudo,
    funkcja,
    przydzial_myszy,
    NVL(myszy_extra, 0) "EXTRA"
FROM Kocury
WHERE
    funkcja = 'MILUSIA'
    OR
    pseudo = 'TYGRYS'
ORDER BY 
    funkcja;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 4
WHERE
    funkcja = 'MILUSIA';

SELECT
    pseudo,
    funkcja,
    przydzial_myszy,
    NVL(myszy_extra, 0) "EXTRA"
FROM Kocury
WHERE
    funkcja = 'MILUSIA'
    OR
    pseudo = 'TYGRYS'
ORDER BY 
    funkcja;

ROLLBACK;

DROP TRIGGER trg_wirus;

--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------
-- Definicja relacji
CREATE TABLE Dodatki_extra (
    pseudo        VARCHAR2(15),
    dodatek_extra NUMBER(3)
);

-- Definicja wyzwalacza
CREATE OR REPLACE TRIGGER trg_dokumentuj_podwyzki_milus
FOR UPDATE OF przydzial_myszy ON Kocury
COMPOUND TRIGGER
    v_czy_update_milusia BOOLEAN := FALSE;
    v_czy_podwyzka       BOOLEAN := FALSE;
    v_dynamic_sql        CLOB;

    BEFORE EACH ROW IS
    BEGIN
        v_czy_update_milusia := :OLD.funkcja = 'MILUSIA';
        v_czy_podwyzka       := :OLD.przydzial_myszy < :NEW.przydzial_myszy;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        IF v_czy_update_milusia AND SYS.LOGIN_USER != 'TYGRYS' AND v_czy_podwyzka THEN
            v_dynamic_sql := v_dynamic_sql || 
                '
                INSERT INTO Dodatki_extra (pseudo, dodatek_extra)
                SELECT
                    pseudo,
                    -10
                FROM Kocury
                WHERE
                    funkcja = ''MILUSIA''
                ';

            EXECUTE IMMEDIATE v_dynamic_sql;
        END IF;
    END AFTER STATEMENT;


END trg_dokumentuj_podwyzki_milus;
/

-- Wywołanie
SELECT
    *
FROM Dodatki_extra;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 2
WHERE
    pseudo = 'LOLA';

SELECT
    *
FROM Dodatki_extra;

ROLLBACK;

DROP TABLE Dodatki_extra;

DROP TRIGGER trg_dokumentuj_podwyzki_milus;

--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
-- a)
BEGIN
    DECLARE
        v_table_count NUMBER;
    BEGIN
        SELECT 
            COUNT(*) 
        INTO 
            v_table_count 
        FROM USER_TABLES 
        WHERE 
            TABLE_NAME = 'MYSZY';

        IF v_table_count != 0 THEN
            EXECUTE IMMEDIATE 'DROP TABLE Myszy CASCADE CONSTRAINTS';
            DBMS_OUTPUT.PUT_LINE('Usunieto tabele `Myszy`.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    EXECUTE IMMEDIATE 
    '
        CREATE TABLE Myszy (
        nr_myszy       NUMBER       CONSTRAINT pk_myszy PRIMARY KEY,
        lowca          VARCHAR2(15) CONSTRAINT fk_lowca REFERENCES Kocury(pseudo),
        zjadacz        VARCHAR2(15) CONSTRAINT fk_zjadacz REFERENCES Kocury(pseudo),
        waga_myszy     NUMBER,
        data_zlowienia DATE,
        data_wydania   DATE
    )
    ';

    DBMS_OUTPUT.PUT_LINE('Utworzono tabele `Myszy`.');
END;
/

-- b)
DECLARE
    v_count NUMBER;
    v_name CONSTANT VARCHAR2(13) := 'SEQ_MYSZY_NUM';
BEGIN
    SELECT
        COUNT(*)
    INTO
        v_count
    FROM USER_SEQUENCES
    WHERE
        SEQUENCE_NAME = v_name;

    IF v_count != 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || v_name;
    END IF;

    EXECUTE IMMEDIATE 
    '
        CREATE SEQUENCE ' || v_name || '
        START WITH 1
        INCREMENT BY 1
        NOCACHE
    ';
END;
/

-- Wypełnianie historii wstecz az do biezacej daty lub daty przed dniem oddania listy
CREATE OR REPLACE PROCEDURE WypenijHistorieMyszy IS
    -- Definicje typów
    TYPE t_pseudo_tab IS TABLE OF Kocury.pseudo%TYPE;
    TYPE t_myszy_tab  IS TABLE OF Myszy%ROWTYPE;

    -- Definicje tabel
    v_kocury t_pseudo_tab;
    v_myszy  t_myszy_tab := t_myszy_tab();

    -- Definicje dat
    v_data_koniec_final CONSTANT DATE := TO_DATE('2026-01-30', 'YYYY-MM-DD');

    v_data_start     DATE := TO_DATE('2004-01-01', 'YYYY-MM-DD');
    v_data_koniec    DATE := CASE WHEN SYSDATE > v_data_koniec_final THEN v_data_koniec_final ELSE SYSDATE END;
    v_miesiac        DATE;
    v_ostatnia_sroda DATE;

    -- Pozostałe zmienne obliczeniowe
    v_myszy_miesiecznie_total NUMBER;
    v_liczba_kotow            NUMBER;
    v_srednio_na_kota         NUMBER;
    v_reszta                  NUMBER;
    v_dni_w_miesiacu          NUMBER;
    v_licznik                 NUMBER := 0;
BEGIN
    -- Zebranie pseudo kocurów w kolejnosci dołączenia do stada
    SELECT DISTINCT
        pseudo
    BULK COLLECT INTO v_kocury
    FROM Kocury
    START WITH szef IS NULL
    CONNECT BY PRIOR pseudo = szef;

    -- Jesli kocurów nie ma, wyjscie
    v_liczba_kotow := v_kocury.COUNT;
    IF v_liczba_kotow = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak kotow - brak danych do uzupelnienia.');
        RETURN;
    END IF;

    -- Obliczenie łącznej liczby myszy do rozdzielenia miesiecznie
    SELECT
        SUM(przydzial_myszy + NVL(myszy_extra, 0))
    INTO
        v_myszy_miesiecznie_total
    FROM Kocury;

    v_miesiac := TRUNC(v_data_start, 'MM');

    -- Główna pętla po miesiącach
    WHILE v_miesiac <= v_data_koniec LOOP
        v_dni_w_miesiacu  := LAST_DAY(v_miesiac) - v_miesiac + 1;
        v_ostatnia_sroda  := NEXT_DAY(LAST_DAY(v_miesiac) - 7, 'WEDNESDAY');
        v_srednio_na_kota := FLOOR(v_myszy_miesiecznie_total / v_liczba_kotow);
        v_reszta          := v_myszy_miesiecznie_total - v_srednio_na_kota * v_liczba_kotow;

        v_myszy.DELETE;

        -- Rozdzielenie myszy pomiędzy kocury
        FOR loop_var_i IN 1..v_liczba_kotow LOOP
            DECLARE
                v_myszy_na_kota NUMBER := v_srednio_na_kota;
            BEGIN
                -- Reszta dzielona po jednej myszy na kota
                IF v_reszta > 0 THEN
                    v_myszy_na_kota := v_myszy_na_kota + 1;
                    v_reszta        := v_reszta - 1;
                END IF;

                -- Wypełnienie tablicy myszy do wstawienia
                FOR loop_var_j IN 1..v_myszy_na_kota LOOP
                    v_licznik := v_licznik + 1;

                    v_myszy.EXTEND;
                    v_myszy(v_myszy.COUNT).nr_myszy       := seq_myszy_num.NEXTVAL;
                    v_myszy(v_myszy.COUNT).lowca          := v_kocury(loop_var_i);
                    v_myszy(v_myszy.COUNT).zjadacz        := v_kocury(loop_var_i);
                    v_myszy(v_myszy.COUNT).waga_myszy     := ROUND(DBMS_RANDOM.VALUE(15, 55), 2);
                    v_myszy(v_myszy.COUNT).data_zlowienia := v_miesiac + TRUNC(DBMS_RANDOM.VALUE(0, TO_NUMBER(TO_CHAR(v_ostatnia_sroda, 'DD'))));
                    v_myszy(v_myszy.COUNT).data_wydania   := v_ostatnia_sroda;
                END LOOP;
            END;
        END LOOP;

        -- Wstawienie danych co miesiąc
        IF v_myszy.COUNT > 0 THEN
                FORALL idx IN v_myszy.FIRST..v_myszy.LAST
                INSERT INTO Myszy VALUES v_myszy(idx);
        END IF;

        v_miesiac := ADD_MONTHS(v_miesiac, 1);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Historia myszy uzupelniona pomyslnie.');
END WypenijHistorieMyszy;
/

BEGIN
    WypenijHistorieMyszy;
END;
/

-- Sprawdzenie wyników
SELECT 
    nr_myszy,
    lowca,
    zjadacz,
    waga_myszy,
    TO_CHAR(data_zlowienia, 'YYYY-MM-DD') "DATA_ZLOWIENIA",
    TO_CHAR(data_wydania, 'YYYY-MM-DD')   "DATA_WYDANIA"
FROM Myszy;

-- Rejestrowanie dziennej historii łowów dla danego kocura
CREATE OR REPLACE PROCEDURE RejestrujDzienneLowy (
    p_pseudo Kocury.pseudo%TYPE
) IS
    -- Definicje typów
    TYPE t_daty_tab IS TABLE OF DATE;
    TYPE t_wagi_tab IS TABLE OF NUMBER;

    -- Definicje tabel
    v_daty t_daty_tab;
    v_wagi t_wagi_tab;

    -- Pozostałe zmienne
    v_pseudo_liczba NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO
        v_pseudo_liczba
    FROM Kocury
    WHERE
        pseudo = p_pseudo;

    IF v_pseudo_liczba = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak kocurow o wskazanym pseudonimie: ' || p_pseudo);
        RETURN;
    END IF;

    EXECUTE IMMEDIATE
     '
        SELECT
            data_zlowienia, 
            waga_myszy
        FROM ' || 'DzienneLowy_' || p_pseudo || '
        WHERE
            pseudo = ' || p_pseudo || '
    '
    BULK COLLECT INTO
        v_daty,
        v_wagi;

    IF v_daty.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak nowych zlowionych myszy dla: ' || p_pseudo);
        RETURN;
    END IF;

    FORALL idx IN v_wagi.FIRST..v_wagi.LAST
    INSERT INTO Myszy VALUES (
        seq_myszy_num.NEXTVAL,
        p_pseudo,
        NULL, -- Zjadacz jeszcze nie okreslony
        v_wagi(idx),
        v_daty(idx),
        NULL -- Data wydania jeszcze nie okreslona
    );
END RejestrujDzienneLowy;
/

-- Przyznanie myszy kocurom
CREATE OR REPLACE PROCEDURE MiesiecznaWyplataMyszy 
IS
    -- Definicje typów
    TYPE t_kot_info IS RECORD (
        pseudo              Kocury.pseudo%TYPE,
        limit_myszy         NUMBER,
        przydzielone_myszy  NUMBER
    );

    TYPE t_koty_tab      IS TABLE OF t_kot_info;
    TYPE t_nr_myszy_tab  IS TABLE OF Myszy.nr_myszy%TYPE;
    TYPE t_pseudo_tab    IS TABLE OF Kocury.pseudo%TYPE;
    TYPE t_date_tab      IS TABLE OF DATE;

    -- Definicje tabel
    v_koty               t_koty_tab;
    v_dostepne_myszy     t_nr_myszy_tab;
    v_wynik_id_myszy     t_nr_myszy_tab := t_nr_myszy_tab();
    v_wynik_zjadacze     t_pseudo_tab   := t_pseudo_tab();

    -- Definicje dat
    v_ostatnia_sroda     DATE := NEXT_DAY(LAST_DAY(SYSDATE) - 7, 'WEDNESDAY');

    -- Pozostałe zmienne
    v_idx_mysz           PLS_INTEGER := 1;
    v_idx_kot            PLS_INTEGER := 1;
    v_pelne_koty_z_rzedu PLS_INTEGER := 0;
    v_liczba_kotow       PLS_INTEGER;
    v_liczba_myszy       PLS_INTEGER;
BEGIN
    IF TRUNC(SYSDATE) != TRUNC(v_ostatnia_sroda) THEN
        RETURN;
    END IF;

    -- Zebranie kocurów zgodnie z hierarchią
    SELECT DISTINCT
        pseudo,
        przydzial_myszy + NVL(myszy_extra, 0),
        0
    BULK COLLECT INTO v_koty
    FROM Kocury
    START WITH szef IS NULL
    CONNECT BY PRIOR pseudo = szef;

    v_liczba_kotow := v_koty.COUNT;

    EXECUTE IMMEDIATE
    '
    SELECT
        COUNT(*)
    INTO
        v_dostepne_myszy
    FROM Myszy
    WHERE
        zjadacz IS NULL;
    ';

    v_liczba_myszy := v_dostepne_myszy.COUNT;

    IF v_liczba_kotow = 0 OR v_liczba_myszy = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak kotow lub myszy - brak danych do przyznania myszy.');
        RETURN;
    END IF;

    -- Główna pętla przydziału myszy
    LOOP
        EXIT WHEN v_idx_mysz > v_liczba_myszy OR v_pelne_koty_z_rzedu >= v_liczba_kotow;

        -- Przydzielenie myszy aktualnemu kocurowi
        IF v_koty(v_idx_kot).przydzielone_myszy < v_koty(v_idx_kot).limit_myszy THEN
            v_wynik_id_myszy.EXTEND;
            v_wynik_zjadacze.EXTEND;

            v_wynik_id_myszy(v_wynik_id_myszy.COUNT) := v_dostepne_myszy(v_idx_mysz);
            v_wynik_zjadacze(v_wynik_zjadacze.COUNT) := v_koty(v_idx_kot).pseudo;

            v_koty(v_idx_kot).przydzielone_myszy     := v_koty(v_idx_kot).przydzielone_myszy + 1;
            v_idx_mysz                               := v_idx_mysz + 1;
            v_pelne_koty_z_rzedu                     := 0;
        ELSE
            -- Jesli kot pelny, zwieksz licznik pelnych kotow z rzedu
            v_pelne_koty_z_rzedu := v_pelne_koty_z_rzedu + 1;
        END IF;

        -- Jesli myszy do rozdysponowania wciaz jeszcze sa, wroc na poczatek
        v_idx_kot := v_idx_kot + 1;
        IF v_idx_kot > v_liczba_kotow THEN
            v_idx_kot := 1;
        END IF;
    END LOOP;

    -- Przyznanie nadmiarowych myszy Tygrysowi
    WHILE v_idx_mysz <= v_liczba_myszy LOOP
        v_wynik_id_myszy.EXTEND;
        v_wynik_zjadacze.EXTEND;

        v_wynik_id_myszy(v_wynik_id_myszy.COUNT) := v_dostepne_myszy(v_idx_mysz);
        v_wynik_zjadacze(v_wynik_zjadacze.COUNT) := 'TYGRYS';
        v_idx_mysz                               := v_idx_mysz + 1;
    END LOOP;

    -- Aktualizacja tabeli
    IF v_wynik_zjadacze.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nie rozdano myszy.');
        RETURN;
    END IF;

    FORALL idx IN 1..v_wynik_id_myszy.COUNT
    UPDATE Myszy
    SET
        zjadacz      = v_wynik_zjadacze(idx),
        data_wydania = SYSDATE
    WHERE
        nr_myszy = v_wynik_id_myszy(idx);
END;
/

BEGIN
    MiesiecznaWyplataMyszy;
END;
/

ROLLBACK;
