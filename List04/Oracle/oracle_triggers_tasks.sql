/*
 * ******************************************************************************
 * @file           : oracle_triggers_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Oracle PL/SQL triggers from List 04.
 * ******************************************************************************
 */

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


-- b)


