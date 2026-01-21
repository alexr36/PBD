/*
Tablica index by - kocury z przydzialami > od sredniej calkowitej
*/

CREATE OR REPLACE PROCEDURE koty_z_przydzialami_wiekszymi_od_sredniej 
IS
    TYPE t_kocur_ps_prz  IS RECORD (pseudo Kocury.pseudo%TYPE, calk_przydz NUMBER);
    TYPE t_kocury_ps_prz IS TABLE OF t_kocur_ps_prz INDEX BY BINARY_INTEGER;
    v_kocury_ps_prz t_kocury_ps_prz;

    v_srednia_calk NUMBER;
    -- v_srednia_bandy NUMBER;

    CURSOR c_kocury IS (
        SELECT
            pseudo,
            przydzial_myszy + NVL(myszy_extra, 0) AS calk
        FROM Kocury
    );
BEGIN
    SELECT
        AVG(przydzial_myszy + NVL(myszy_extra, 0))
    INTO
        v_srednia_calk
    FROM Kocury;

    FOR kocur IN c_kocury LOOP

        /*
        SELECT
            AVG(przydzial_myszy_NVL(myszy_extra, 0))
        INTO
            v_srednia_bandy
        FROM Kocury;
        */

        -- IF kocur.calk > v_srednia_bandy THEN
        IF kocur.calk > v_srednia_calk THEN 
            v_kocury_ps_prz(v_kocury_ps_prz.COUNT) := kocur;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Srednia: ' || ROUND(v_srednia_calk, 2));
    FOR idx IN v_kocury_ps_prz.FIRST..v_kocury_ps_prz.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Pseudo: ' || v_kocury_ps_prz(idx).pseudo || ' Przydzial: ' || v_kocury_ps_prz(idx).calk_przydz);
    END LOOP;
END koty_z_przydzialami_wiekszymi_od_sredniej;
/

BEGIN
    KOTY_Z_PRZYDZIALAMI_WIEKSZYMI_OD_SREDNIEJ;
END;
/



/*
Data parametr - kocur o incydencie najbzlizszym dacie.
*/

CREATE OR REPLACE FUNCTION data_najblizszego_incydentu_w_bandzie (
    p_data DATE,
    p_nazwa_bandy Bandy.nazwa%TYPE
) 
RETURN DATE 
IS
    v_wynik DATE;
BEGIN
    SELECT 
        data_incydentu
    INTO 
        v_wynik
    FROM (
        SELECT *
        FROM (
            SELECT 
                hi.data_incydentu
            FROM Historia_incydentow hi
            WHERE 
                hi.pseudo IN (
                    SELECT 
                        k.pseudo
                    FROM Kocury k
                        JOIN Bandy b ON b.nr_bandy = k.nr_bandy
                    WHERE 
                        b.nazwa = p_nazwa_bandy
                )
            ORDER BY 
                hi.data_incydentu DESC
        )
        WHERE 
            ROWNUM <= 5
        ORDER BY 
            ABS(p_data - data_incydentu) 
    )
    FETCH FIRST 1 ROWS ONLY;

    RETURN v_wynik;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END data_najblizszego_incydentu_w_bandzie;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(data_najblizszego_incydentu_w_bandzie(SYSDATE, 'BIALI LOWCY'), 'YYYY-MM-DD'));
END;
/

/*

*/

DECLARE
    -- rekord trzymający dane wyniku
    TYPE t_incydent IS RECORD (
        pseudo            Kocury.pseudo%TYPE,
        data_incydentu    Historia_incydentow.data_incydentu%TYPE,
        poziom_agresji    Historia_incydentow.poziom_agresji%TYPE
    );

    -- tabela indeksowana rekordów
    TYPE t_tab_incydent IS TABLE OF t_incydent INDEX BY BINARY_INTEGER;
    v_wyniki t_tab_incydent;

    v_idx NUMBER := 0;
BEGIN
    FOR b IN (
        SELECT nr_bandy, nazwa
        FROM Bandy
    ) LOOP
        
        BEGIN
            SELECT 
                hi.pseudo,
                hi.data_incydentu,
                hi.poziom_agresji
            INTO 
                v_wyniki(v_idx).pseudo,
                v_wyniki(v_idx).data_incydentu,
                v_wyniki(v_idx).poziom_agresji
            FROM Historia_incydentow hi
            WHERE hi.pseudo IN (
                SELECT pseudo
                FROM Kocury
                WHERE nr_bandy = b.nr_bandy
            )
            ORDER BY hi.poziom_agresji DESC, hi.data_incydentu DESC
            FETCH FIRST 1 ROWS ONLY;

            v_idx := v_idx + 1;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Najbardziej agresywne incydenty w bandach:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');

    FOR idx IN v_wyniki.FIRST .. v_wyniki.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Pseudo: ' || v_wyniki(idx).pseudo ||
            ' | Data: ' || TO_CHAR(v_wyniki(idx).data_incydentu, 'YYYY-MM-DD') ||
            ' | Poziom agresji: ' || v_wyniki(idx).poziom_agresji
        );
    END LOOP;
END;
/