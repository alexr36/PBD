/*
 * *****************************************************************************
 * @file           : microsoft_blocks_tasks.sql
 * @author         : Alex Rogoziński
 * @brief          : This file contains solutions to tasks related to 
                     Microsoft T-SQL blocks.
 * *****************************************************************************
 */

--------------------------------------------------------------------------------
-- TASK 2
--------------------------------------------------------------------------------
DECLARE @pseudo_input VARCHAR(15) = 'tyGrYs'

DECLARE
    @pseudo                  VARCHAR(15),
    @imie                    VARCHAR(15),
    @nazwa_bandy             VARCHAR(20),
    @czy_ma_wrogow           VARCHAR(3),
    @czy_wiekszy_od_sredniej VARCHAR(3),
    @w_stadku_od             DATE,
    @przydzial_myszy         INT,
    @srednia_bandy           FLOAT;

IF NOT EXISTS (
    SELECT
        pseudo
    FROM Kocury
    WHERE
        pseudo = UPPER(@pseudo_input)
)
BEGIN
    PRINT 'ERROR: Kot o podanym pseudonimie nie istnieje: ' + UPPER(@pseudo_input);
    RETURN;
END;

SELECT
    @pseudo          = k.pseudo,
    @imie            = k.imie,
    @nazwa_bandy     = b.nazwa,
    @w_stadku_od     = k.w_stadku_od,
    @przydzial_myszy = k.przydzial_myszy
FROM Kocury k
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
WHERE
    k.pseudo = UPPER(@pseudo_input);

IF EXISTS (
    SELECT
        pseudo
    FROM Wrogowie_kocurow
    WHERE
        pseudo = UPPER(@pseudo_input)
)
    SET @czy_ma_wrogow = 'TAK';
ELSE
    SET @czy_ma_wrogow = 'NIE';

SELECT
    @srednia_bandy = AVG(12.0 * przydzial_myszy)
FROM Kocury
WHERE
    nr_bandy = (
        SELECT
            nr_bandy
        FROM Kocury
        WHERE
            pseudo = UPPER(@pseudo_input)
    );

IF 12 * @przydzial_myszy > @srednia_bandy
    SET @czy_wiekszy_od_sredniej = 'TAK';
ELSE
    SET @czy_wiekszy_od_sredniej = 'NIE';

PRINT 'Pseudo:'                                              + SPACE(46) + @pseudo;
PRINT 'Imie:'                                                + SPACE(48) + @imie;
PRINT 'Nazwa bandy:'                                         + SPACE(41) + @nazwa_bandy;
PRINT 'Czy ma wrogow:'                                       + SPACE(39) + @czy_ma_wrogow;
PRINT 'Czy roczny przydzial jest wiekszy od sredniej bandy:' + SPACE(1)  + @czy_wiekszy_od_sredniej;
PRINT 'Dzien przystapienia do stada:'                        + SPACE(24) + CAST(DAY(@w_stadku_od) AS VARCHAR);
PRINT 'Miesiac przystapienia do stada:'                      + SPACE(22) + DATENAME(month, @w_stadku_od);
PRINT 'Rok przystapienia do stada:'                          + SPACE(26) + CAST(YEAR(@w_stadku_od) AS VARCHAR);
GO

--------------------------------------------------------------------------------
-- TASK 4
--------------------------------------------------------------------------------
DECLARE
    @t_tabela_kocury TABLE (
        id       INT IDENTITY(1,1),
        pseudo   VARCHAR(15),
        nr_bandy INT PRIMARY KEY,
        staz     INT
    );
DECLARE
    @v_pseudo   VARCHAR(15),
    @v_nr_bandy INT,
    @v_staz     INT;
DECLARE    
    c_kursor CURSOR FOR
        SELECT 
            pseudo, 
            nr_bandy, 
            staz
        FROM @t_tabela_kocury;
BEGIN TRY
    WITH Minimalne_staze AS (
        SELECT
            nr_bandy,
            DATEDIFF(DAY, MAX(w_stadku_od), GETDATE()) AS staz
        FROM Kocury
        GROUP BY
            nr_bandy
    )
    INSERT INTO @t_tabela_kocury (pseudo, nr_bandy, staz)
    SELECT
        k.pseudo,
        k.nr_bandy,
        ROUND(ms.staz, 0)
    FROM Kocury k
        INNER JOIN Minimalne_staze ms ON ms.nr_bandy = k.nr_bandy
    GROUP BY
        k.pseudo,
        k.nr_bandy,
        ms.staz
    HAVING
        DATEDIFF(DAY, MAX(k.w_stadku_od), GETDATE()) = ms.staz;

    IF NOT EXISTS (SELECT pseudo FROM @t_tabela_kocury)
        THROW 50001, 'ERROR: Brak rekordow do wyswietlenia.', 1;

    OPEN c_kursor;
    FETCH NEXT FROM c_kursor INTO @v_pseudo, @v_nr_bandy, @v_staz;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Pseudo:'   + SPACE(3) + @v_pseudo;
        PRINT 'Nr bandy:' + SPACE(1) + CAST(@v_nr_bandy AS VARCHAR);
        PRINT 'Staz:'     + SPACE(4) + CAST(@v_staz AS VARCHAR) + ' dni';
        PRINT ''

        FETCH NEXT FROM c_kursor INTO @v_pseudo, @v_nr_bandy, @v_staz;
    END

    CLOSE c_kursor;
    DEALLOCATE c_kursor;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- TASK 5
--------------------------------------------------------------------------------
DECLARE
    c_kursor_data CURSOR FOR
        SELECT
            k.imie,
            k.pseudo,
            k.przydzial_myszy,
            f.max_myszy
        FROM Kocury k
            INNER JOIN Funkcje f ON f.funkcja = k.funkcja
        ORDER BY
            k.przydzial_myszy DESC;
DECLARE
    c_print_kursor CURSOR FOR
        SELECT
            imie,
            przydzial_myszy
        FROM Kocury
        ORDER BY
            w_stadku_od;
DECLARE
    @v_imie            VARCHAR(15),
    @v_pseudo          VARCHAR(15),
    @v_przydzial_myszy INT,
    @v_max_myszy       INT,
    @v_zmiany          INT = 0,
    @v_suma_przydz     INT = 0,
    @v_nowy_przydzial  INT
BEGIN
    SELECT
        @v_suma_przydz = SUM(przydzial_myszy)
    FROM Kocury;

    BEGIN TRANSACTION;
    
    WHILE @v_suma_przydz <= 1050
    BEGIN
        OPEN c_kursor_data;
        FETCH NEXT FROM c_kursor_data INTO @v_imie, @v_pseudo, @v_przydzial_myszy, @v_max_myszy;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @v_nowy_przydzial = ROUND(1.1 * @v_przydzial_myszy, 0);

            IF @v_nowy_przydzial > @v_max_myszy
                SET @v_nowy_przydzial = @v_max_myszy;

            IF @v_nowy_przydzial != @v_przydzial_myszy
                SET @v_zmiany += 1;

            UPDATE Kocury SET przydzial_myszy = @v_nowy_przydzial WHERE pseudo = @v_pseudo;

            FETCH NEXT FROM c_kursor_data INTO @v_imie, @v_pseudo, @v_przydzial_myszy, @v_max_myszy;
        END

        SELECT
            @v_suma_przydz = SUM(przydzial_myszy)
        FROM Kocury;

        CLOSE c_kursor_data;
    END

    DEALLOCATE c_kursor_data;

    PRINT 'Calk. przydzial w stadku ' + CAST(@v_suma_przydz AS VARCHAR) + ' Zmian - ' + CAST(@v_zmiany AS VARCHAR);
    PRINT '';
    PRINT LEFT('IMIE' + REPLICATE(' ', 12), 16) + 'Myszki po podwyzce';
    PRINT REPLICATE('-', 15) + ' ' + REPLICATE('-', 18);

    OPEN c_print_kursor;
    FETCH NEXT FROM c_print_kursor INTO @v_imie, @v_przydzial_myszy;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT LEFT(@v_imie + REPLICATE(' ', 16), 16) + RIGHT(@v_przydzial_myszy + REPLICATE(' ', 18), 18);
        FETCH NEXT FROM c_print_kursor INTO @v_imie, @v_przydzial_myszy;
    END

    CLOSE c_print_kursor;
    DEALLOCATE c_print_kursor;
    ROLLBACK;
END;
GO

--------------------------------------------------------------------------------
-- TASK 6
--------------------------------------------------------------------------------
DECLARE
    c_kursor_zjada CURSOR FOR
        SELECT TOP 5
            pseudo,
            przydzial_myszy + ISNULL(myszy_extra, 0)
        FROM Kocury
        ORDER BY
            przydzial_myszy + ISNULL(myszy_extra, 0) DESC;
DECLARE
    @v_numer  INT = 1,
    @v_pseudo VARCHAR(15),
    @v_zjada  INT;
BEGIN
    PRINT RIGHT('Nr' + REPLICATE(' ', 2), 4) + RIGHT('Pseudonim' + REPLICATE(' ', 2), 11) + 'Zjada';
    PRINT REPLICATE('-', 20);

    OPEN c_kursor_zjada;

    FETCH NEXT FROM c_kursor_zjada INTO @v_pseudo, @v_zjada;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT RIGHT(@v_numer, 4) + SPACE(3) + RIGHT(@v_pseudo + REPLICATE(' ', 5), 11) + REPLICATE('', 1) + CAST(@v_zjada AS VARCHAR);
        FETCH NEXT FROM c_kursor_zjada INTO @v_pseudo, @v_zjada;
        SET @v_numer += 1;
    END
    CLOSE c_kursor_zjada;
    DEALLOCATE c_kursor_zjada;
END;
GO

--------------------------------------------------------------------------------
-- TASK 7
--------------------------------------------------------------------------------
-- a)
DECLARE
    @przelozeni_num INT = 2,
    @dynamic_sql    NVARCHAR(MAX),
    @index          INT = 1,
    @index_nvarchar NVARCHAR(3);

-- Poczatek kwerendy
SET @dynamic_sql = 'SELECT k0.imie AS Imie';

-- Wyznaczenie danych do wypisania
WHILE @index <= @przelozeni_num
BEGIN
    SET @index_nvarchar = CAST(@index AS NVARCHAR);
    SET @dynamic_sql += N', ISNULL(k' + @index_nvarchar + N'.imie, '''') AS [Szef ' + @index_nvarchar + N']';
    SET @index += 1;
END;

SET @dynamic_sql += N' FROM Kocury k0';

SET @index = 1;

-- Wyznaczenie zlaczen
WHILE @index <= @przelozeni_num
BEGIN
    SET @index_nvarchar = CAST(@index AS NVARCHAR);
    SET @dynamic_sql += N' LEFT JOIN Kocury k' + @index_nvarchar + N' ON k' + @index_nvarchar 
                      + N'.pseudo = k' + CAST(@index - 1 AS NVARCHAR) + N'.szef';

    SET @index += 1;
END;

-- Dodanie warunkow poczatkowych i porzadku
SET @dynamic_sql += N'
    WHERE 
        k0.funkcja IN (''KOT'', ''MILUSIA'')
    ORDER BY 
        k0.imie;
    ';

-- Wywolanie
EXEC sp_executesql @dynamic_sql;
