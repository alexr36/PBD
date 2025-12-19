/*
 * *****************************************************************************
 * @file           : microsoft_procedures_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Microsoft T-SQL procedures.
 * *****************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 9
--------------------------------------------------------------------------------
-- Definicja
CREATE OR ALTER PROCEDURE ZmienPrzydzialDlaFunkcji
    @p_funkcja         VARCHAR(10),
    @p_przydzial_myszy INT
AS
BEGIN
    -- Weryfikacja poprawnosci wartosci przydzialu
    IF @p_przydzial_myszy IS NULL OR @p_przydzial_myszy < 0
        THROW 50000, 'Nieprawidlowy przydzial myszy.', 1;

    -- Aktualizacja kocurow o podanej funkcji
    UPDATE Kocury
    SET przydzial_myszy = @p_przydzial_myszy
    WHERE
        funkcja = UPPER(@p_funkcja);

    IF @@ROWCOUNT = 0
        THROW 50001, 'Brak kotow o podanej funkcji.', 1;
END;
GO

-- Wywolanie
DECLARE
    c_kursor CURSOR FOR
        SELECT
            pseudo,
            przydzial_myszy,
            funkcja
        FROM Kocury
        ORDER BY
            funkcja;
DECLARE
    @v_funkcja         VARCHAR(10) = UPPER('lowczy'),
    @v_przydzial_myszy INT         = 22,
    @v_pseudo_temp     VARCHAR(15),
    @v_przydzial_temp  INT,
    @v_funkcja_temp    VARCHAR(10);
BEGIN TRY
    PRINT 'Przed aktualizacja:';

    OPEN c_kursor;
    FETCH NEXT FROM c_kursor
    INTO
        @v_pseudo_temp,
        @v_przydzial_temp,
        @v_funkcja_temp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT(@v_pseudo_temp, ' ', @v_przydzial_temp, ' ', @v_funkcja_temp);
        FETCH NEXT FROM c_kursor
        INTO
            @v_pseudo_temp,
            @v_przydzial_temp,
            @v_funkcja_temp;
    END;
    CLOSE c_kursor;

    BEGIN TRANSACTION;

    EXEC ZmienPrzydzialDlaFunkcji @v_funkcja, @v_przydzial_myszy;

    PRINT '';
    PRINT 'Po aktualizacja dla ' + UPPER(CAST(@v_funkcja AS VARCHAR) + ':');
    OPEN c_kursor;
    FETCH NEXT FROM c_kursor
    INTO
        @v_pseudo_temp,
        @v_przydzial_temp,
        @v_funkcja_temp;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT(@v_pseudo_temp, ' ', @v_przydzial_temp, ' ', @v_funkcja_temp);
        FETCH NEXT FROM c_kursor
        INTO
            @v_pseudo_temp,
            @v_przydzial_temp,
            @v_funkcja_temp;
    END;
    CLOSE c_kursor;

    DEALLOCATE c_kursor;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    PRINT ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- TASK 10
--------------------------------------------------------------------------------
-- Definicja
CREATE OR ALTER FUNCTION PodatekPoglowny (@p_pseudo VARCHAR(15)) RETURNS INT
AS
BEGIN
DECLARE
    @v_podwladni_cnt INT,
    @v_wrogowie_cnt  INT,
    @v_podatek       INT         = 0,
    @v_pseudo        VARCHAR(15) = UPPER(@p_pseudo),
    @v_plec          CHAR(1);

    -- Podatek podstawowy - obliczenie 5% calkowitego przydzialu myszy
    -- dla kota o danym pseudonimie
    SELECT
        @v_podatek = ROUND(0.05 * (przydzial_myszy + ISNULL(myszy_extra, 0)), 0),
        @v_plec    = plec
    FROM Kocury
    WHERE
        pseudo = @v_pseudo;

    -- Podatek od braku podwladnych - policzenie dla ilu kotow kot o danym 
    -- pseudonimie jest szefem
    SELECT
        @v_podwladni_cnt = COUNT(*)
    FROM Kocury
    WHERE
        szef = @v_pseudo;

    IF @v_podwladni_cnt = 0
        SET @v_podatek = @v_podatek + 2;

    -- Podatek od braku wrogow - policzenie ile jest wystapien danego
    -- pseudonimu w tabeli `Wrogowie_kocurow`
    SELECT
        @v_wrogowie_cnt = COUNT(*)
    FROM Wrogowie_kocurow
    WHERE
        pseudo = @v_pseudo;

    IF @v_wrogowie_cnt = 0
        SET @v_podatek = @v_podatek + 1;
    
    -- Podatek od kocurow (dodany) - podatek w postaci 5 myszy dla kocurow 
    -- (plci meskiej)
    IF @v_plec = 'M'
        SET @v_podatek = @v_podatek + 5;

    RETURN @v_podatek;
END;
GO

-- Wywolanie
DECLARE 
    @pseudo_input VARCHAR(15) = 'tygrys';
BEGIN
    BEGIN TRY
        PRINT CONCAT('Podatek dla ', UPPER(@pseudo_input), ': ', dbo.PodatekPoglowny(@pseudo_input), ' myszy');
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

--------------------------------------------------------------------------------
-- TASK 11
--------------------------------------------------------------------------------

