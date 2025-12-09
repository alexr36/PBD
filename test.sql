/**
Wyswietlić sredni przydzial myszy kotów płci męskiej którzy nie mają wrogow i są
w bandzie której sredni przydzial myszy przekracza 55. Podzapytanie ma być poza 
from i poza select, nie stosować polaczenia pionowego ani widokow.
*/
SELECT
    k.pseudo,
    AVG(k.przydzial_myszy) AS przydzial
FROM Kocury k
    LEFT JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
WHERE
    k.plec = 'M'
    AND
    wk.imie_wroga IS NULL
    AND
    k.nr_bandy IN (
        SELECT
            k1.nr_bandy
        FROM Kocury k1
        GROUP BY
            k1.nr_bandy
        HAVING
            AVG(k1.przydzial_myszy) > 55
    )
GROUP BY
    k.pseudo;

/**
Sposrod kotow tej samej plci należących do tych samych band co (2 pseudonimy 
placek, rura) albo do band gdzie sredni przydzial myszy jest większy od 50 i 
dostają 10% myszy więcej niż min_myszy w ich bandzie, wyznaczyć maksymalny 
przydzial myszy i ilość kotow które nie dostają myszy-ekstra
uzyc zlaczenia poziomego, podzapytania (poza select i from), grupowanie, bez 
zlaczenia pionowego
*/
SELECT
    k.plec,
    MAX(k.przydzial_myszy) AS max_przydzial,
    SUM(CASE WHEN k.myszy_extra THEN 1 ELSE 0 END) AS bez_extra
FROM Kocury k
WHERE
    k.nr_bandy IN (
        SELECT
            k1.nr_bandy
        FROM Kocury k1
        WHERE
            k1.pseudo IN ('PLACEK', 'RURA')
    )
    OR (
    k.nr_bandy IN (
        SELECT
            k2.nr_bandy
        FROM Kocury k2
        GROUP BY
            k2.nr_bandy,
            k2.przydzial_myszy
        HAVING
            50 < AVG(k2.przydzial_myszy)
            AND
            k2.przydzial_myszy = 1.1 * MIN(k2.przydzial_myszy)
    )
    
    )
GROUP BY
    k.plec;

/**
Podaj pseudo i nr bandy kocurów płci męskiej którzy nie posiadają wrogów oraz 
należące do band gdzie średni przydział myszy kotów o płci męskiej jest powyżej 
55. Wykorzystać podzapytanie, (?Laczenie?) poziome oraz grupowanie.
*/
SELECT
    k.pseudo,
    k.nr_bandy
FROM Kocury k
    LEFT JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
WHERE
    k.plec = 'M'
    AND
    wk.imie_wroga IS NULL
    AND
    k.nr_bandy IN (
        SELECT
            b.nr_bandy
        FROM Bandy b
            INNER JOIN Kocury k1 ON k1.nr_bandy = b.nr_bandy
        WHERE
            k1.plec = 'M'
        GROUP BY
            b.nr_bandy
        HAVING
            AVG(k1.przydzial_myszy) > 55
    );


/**
Założyć że w bazie jest dodatkowa tabela myszy gdzie sa atrybuty: nr_myszy, 
waga_myszy, pseudo_zjadacza, pseudo_lapacza, gdzie waga_myszy jest obowiązkowa i 
pseudo_lapacza. Znalezc bandy ktore maja wiecej niz 4 czlonkow i których 
członkowie zjedli wiecej myszy niż zlapali
*/
WITH Zlapane AS (
    SELECT
        pseudo_lapacza AS pseudo,
        COUNT(*) AS zlapal
    FROM Myszy
),
Zjedzone AS (
    SELECT
        pseudo_zjadacza AS pseudo,
        COUNT(*) AS zjadl
    FROM Myszy
)
SELECT DISTINCT
    b.nazwa
FROM Bandy b
    INNER JOIN Kocury k ON k.nr_bandy = b.nr_bandy
    LEFT JOIN Zlapane zl ON zl.pseudo = k.pseudo
    LEFT JOIN Zjedzone zj ON zj.pseudo = k.pseudo
WHERE 
    b.nr_bandy IN (
        SELECT
            nr_bandy 
        FROM Kocury
        GROUP BY 
            nr_bandy
        HAVING
            COUNT(*) > 4
    )
GROUP BY
    b.nazwa
HAVING
    SUM(NVL(zj.zjadl, 0)) > SUM(NVL(zl.zlapal, 0));



/*
1. Wyświetl pseudonim oraz liczbę wrogów każdego kota, ale tylko tych
kotów, którzy mają co najmniej 2 wrogów.
*/
SELECT
    k.pseudo,
    COUNT(wk.imie_wroga)
FROM Kocury k
    INNER JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
GROUP BY
    k.pseudo
HAVING
    COUNT(wk.imie_wroga) > 1;

/*
2. Podaj pseudonimy wszystkich kotów, które mają przydział myszy
większy niż średni przydział w ich bandzie.
*/
WITH SrednieBand AS (
    SELECT
        k.nr_bandy,
        AVG(k.przydzial_myszy) AS srednia
    FROM Kocury k
    GROUP BY 
        k.nr_bandy
)
SELECT
    k.pseudo
FROM Kocury k
    INNER JOIN SrednieBand sb ON sb.nr_bandy = k.nr_bandy
WHERE
    k.przydzial_myszy > sb.srednia;

/*
3. Wyświetl koty, które mają większy przydział myszy niż którakolwiek
kotka w ich bandzie.
*/
WITH Kotki AS (
    SELECT
        k1.nr_bandy AS banda,
        MAX(k1.przydzial_myszy) AS przydzial
    FROM Kocury k1
    WHERE
        k1.plec = 'D'
    GROUP BY
        banda
)
SELECT
    k.*
FROM Kocury k
    INNER JOIN Kotki ki ON ki.banda = k.nr_bandy
WHERE
    k.przydzial_myszy > ki.przydzial;

/*
4. Znajdź bandy, w których różnica między maksymalnym a minimalnym
przydziałem myszy przekracza 20.
*/
WITH StatyBand AS (
    SELECT
        k1.nr_bandy AS banda,
        MIN(k1.przydzial_myszy) AS min_przydz,
        MAX(k1.przydzial_myszy) AS max_przydz
    FROM Kocury k1
    GROUP BY
        banda
)
SELECT
    b.*
FROM Bandy b
    INNER JOIN StatyBand sb ON sb.banda = b.nr_bandy
WHERE
    sb.max_przydz - sb.min_przydz > 20;

/*
5. Wyświetl informacje o kotach, które:
– nie mają wrogów,
– mieszkają w bandach posiadających co najmniej 5 członków.
*/
WITH Bandy_licznosci AS (
    SELECT
        b1.nr_bandy AS banda,
        COUNT(*) AS licznosc
    FROM Kocury k1
        INNER JOIN Bandy b1 ON b1.nr_bandy = k1.nr_bandy
    GROUP BY
        banda
)
SELECT
    k.*
FROM Kocury k
    INNER JOIN Bandy_licznosci bl ON bl.banda = k.nr_bandy
    LEFT JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
WHERE
    wk.imie_wroga IS NULL
    AND
    bl.licznosc >= 5;

/*
6. Znajdź wszystkie pary kot–wrogowie, w których imię kota i imię wroga
zaczynają się tą samą literą.
*/
SELECT
    k.imie AS imie_kota,
    wk.imie_wroga AS imie_wroga
FROM Kocury k
    INNER JOIN Wrogowie_kocurow wk ON wk.pseudo = k.pseudo
WHERE
    SUBSTR(k.imie, 0, 1) = SUBSTR(wk.imie_wroga, 0, 1);

/*
7. Wyświetl koty (pseudo, funkcja, przydział myszy), które mają
drugi największy przydział w swojej bandzie (podzapytanie skorelowane).
*/
SELECT
    k.pseudo,
    k.funkcja,
    k.przydzial_myszy
FROM Kocury k
WHERE
    1 = (
        SELECT
            COUNT(k1.przydzial_myszy)
        FROM Kocury k1
        WHERE
            k1.nr_bandy = k.nr_bandy
            AND
            k1.przydzial_myszy > k.przydzial_myszy
    );

/*
8. Podaj pseudonimy kotów, których szefowie pełnią funkcję BANDZIOR
(bez użycia hierarchii CONNECT BY).
*/
WITH Bandziory AS (
    SELECT
        k1.pseudo AS pseudo_bandziora
    FROM Kocury k1
    WHERE
        k1.funkcja = 'BANDZIOR'
)
SELECT
    k.pseudo,
    k.szef
FROM Kocury k
    INNER JOIN Bandziory b ON b.pseudo_bandziora = k.szef;

/*
9. Podaj liczbę kotów przypadających na każdą funkcję, ale tylko
w bandach o średnim przydziale > 50.
*/
WITH PrzydzialyBand AS (
    SELECT
        k1.nr_bandy,
        AVG(k1.przydzial_myszy) AS srednia
    FROM Kocury k1
    GROUP BY
        k1.nr_bandy
)
SELECT
    k.funkcja,
    COUNT(k.pseudo)
FROM Kocury k
    INNER JOIN Funkcje f ON f.funkcja = k.funkcja
    INNER JOIN PrzydzialyBand pb ON pb.nr_bandy = k.nr_bandy
WHERE
    pb.srednia > 50
GROUP BY
    k.funkcja;


/*
10. Dla każdego kota wyświetl jego pseudonim oraz sumę przydziałów
wszystkich kotów z jego bandy.
*/
SELECT
    k.pseudo,
    k2.suma
FROM Kocury k
    INNER JOIN (
        SELECT
            k1.nr_bandy,
            SUM(k1.przydzial_myszy) AS suma
        FROM Kocury k1
        GROUP BY
            k1.nr_bandy
    ) k2 ON k2.nr_bandy = k.nr_bandy;

/*
11. Wyświetl ścieżkę hierarchii szefów dla każdego kota (SYS_CONNECT_BY_PATH).
*/
SELECT
    k.pseudo,
    SYS_CONNECT_BY_PATH(k.szef, ' ') AS hierarchia_szefow
FROM Kocury k
START WITH k.szef IS NULL
CONNECT BY PRIOR k.pseudo = k.szef;

/*
12. Podaj wszystkich podwładnych BOLKA na wszystkich poziomach — użyj
CONNECT BY PRIOR i LEVEL.
*/
SELECT
    k.szef,
    k.pseudo,
    LEVEL
FROM Kocury k
START WITH k.szef = 'BOLEK'
CONNECT BY PRIOR k.pseudo = k.szef;

/*
13. Oznacz każdego kota numerem poziomu w hierarchii oraz liczbą jego
podwładnych (funkcje analityczne + hierarchia).
*/
WITH Hierarchia AS (
    SELECT
        k.pseudo,
        k.szef,
        LEVEL AS lvl
    FROM Kocury k
    START WITH k.szef IS NULL
    CONNECT BY PRIOR k.pseudo = k.szef
),
LiczbyPodwladnych AS (
    SELECT
        h.szef,
        COUNT(h.pseudo) AS liczba
    FROM Hierarchia h
    GROUP BY
        h.szef
)
SELECT
    h.lvl,
    k.pseudo,
    NVL(lp.liczba, 0)
FROM Kocury k
    INNER JOIN Hierarchia h ON h.pseudo = k.pseudo
    LEFT JOIN LiczbyPodwladnych lp ON lp.szef = h.pseudo
ORDER BY
    h.lvl;

/*
14. Znajdź koty, które są jedynymi podwładnymi swoich szefów.
*/
WITH Hierarchia AS (
    SELECT
        k.pseudo,
        k.szef
    FROM Kocury k
    START WITH k.szef IS NULL
    CONNECT BY PRIOR k.pseudo = k.szef
),
LiczbyPodwladnych AS (
    SELECT
        h.szef,
        COUNT(h.pseudo) AS liczba
    FROM Hierarchia h
    WHERE
        h.szef IS NOT NULL
    GROUP BY
        h.szef
)
SELECT 
    k.pseudo
FROM Kocury k
    INNER JOIN LiczbyPodwladnych lp ON lp.szef = k.szef
WHERE
    lp.liczba = 1;

/*
15. Wyświetl kota, który ma najdłuższą ścieżkę hierarchii przełożonych.
*/
WITH Hierarchia AS (
    SELECT
        k.pseudo,
        k.szef
    FROM Kocury k
    CONNECT BY PRIOR k.pseudo = k.szef
),
LiczbySzefow AS (
    SELECT
        h.pseudo,
        COUNT(h.szef) AS liczba
    FROM Hierarchia h
    GROUP BY
        h.pseudo
    ORDER BY 
        liczba DESC
)
SELECT 
    licz_szef.pseudo,
    licz_szef.liczba
FROM LiczbySzefow licz_szef
WHERE
    ROWNUM = 1;

/*
16. Wyświetl wszystkie incydenty kota TYGRYS uporządkowane rosnąco
według poziomu agresji i daty.
*/
SELECT
    *
FROM Historia_Incydentow
WHERE 
    pseudo = 'TYGRYS'
ORDER BY
    poziom_agresji,
    data_incydentu;

/*
17. Dla każdego kota wyświetl liczbę incydentów zakończonych wynikiem
"WROG".
*/
SELECT
    *
FROM Historia_Incydentow
WHERE
    wynik = 'WROG';

/*
18. Wyświetl kota, który najczęściej przegrywał (wynik = 'WROG').
*/
WITH Przegrane AS (
    SELECT
        pseudo,
        COUNT(*) AS liczba
    FROM Historia_Incydentow
    WHERE
        wynik = 'WROG'
    GROUP BY
        pseudo
    ORDER BY
        liczba DESC
)
SELECT
    k.*,
    p.liczba
FROM Kocury k
    INNER JOIN Przegrane p ON p.pseudo = k.pseudo
WHERE
    ROWNUM = 1;

/*
19. Podaj średni poziom agresji w incydentach dla każdego kota.
*/
SELECT
    pseudo,
    ROUND(AVG(poziom_agresji), 2)
FROM Historia_Incydentow
GROUP BY
    pseudo;

/*
20. Znajdź wszystkie incydenty, w których straty myszy były większe
niż średnie straty danego kota.
*/
WITH StratyIncydentow AS (
    SELECT
        pseudo,
        ROUND(AVG(straty_myszy), 2) AS srednie_straty
    FROM Historia_Incydentow
    GROUP BY
        pseudo
)
SELECT
    *
FROM Historia_Incydentow hi
    INNER JOIN StratyIncydentow si ON si.pseudo = hi.pseudo
WHERE
    hi.straty_myszy > si.srednie_straty;

/*
21. Podaj koty, które w 2003 roku miały co najmniej 3 incydenty
o poziomie agresji ≥ 7.
*/
SELECT 
    k.pseudo
FROM Kocury k
    INNER JOIN Historia_Incydentow hi ON hi.pseudo = k.pseudo
WHERE 
    EXTRACT(YEAR FROM hi.data_incydentu) = 2003
    AND 
    hi.poziom_agresji >= 7
GROUP BY 
    k.pseudo
HAVING 
    COUNT(*) >= 3;

/*
22. Znajdź incydenty, które trwały dłużej niż 2 × średni czas trwania
incydentów danego kota.
*/
WITH SrednieCzasy AS (
    SELECT
        pseudo,
        AVG(czas_trwania_min) AS sredni_czas
    FROM Historia_Incydentow
    GROUP BY
        pseudo
)
SELECT
    *
FROM Historia_Incydentow hi
    INNER JOIN SrednieCzasy sc ON sc.pseudo = hi.pseudo
WHERE
    hi.czas_trwania_min > 2 * sc.sredni_czas;

/*
23. Wyświetl ranking kotów według sumy strat myszy z ostatnich 3 lat
ich aktywności (funkcje analityczne: RANGE/ROWS OVER).
*/



/*
24. Dla każdego kota wyświetl pierwszy i ostatni incydent w historii
(MIN(data_incydentu), MAX(data_incydentu)).
*/
SELECT
    pseudo,
    MIN(data_incydentu) AS pierwszy,
    MAX(data_incydentu) AS ostatni
FROM Historia_Incydentow
GROUP BY
    pseudo;

/*
25. Znajdź koty, które nigdy nie miały wyniku „REMIS”.
*/
SELECT
    pseudo
FROM Historia_Incydentow
WHERE
    pseudo NOT IN (
        SELECT
            pseudo
        FROM Historia_Incydentow
        WHERE
            wynik = 'REMIS'
    )
GROUP BY pseudo;

/*
26. Dla każdego kota policz średnią liczbę świadków incydentów.
*/
SELECT
    pseudo,
    ROUND(AVG(liczba_swiadkow), 0)
FROM Historia_Incydentow
GROUP BY
    pseudo;

/*
27. Podaj kota, którego incydenty miały najwyższe średnie tempo:
tempo = poziom_agresji / czas_trwania_min.
*/
WITH SrednieTempa AS (
    SELECT
        pseudo,
        ROUND(AVG(poziom_agresji / czas_trwania_min), 2) AS srednie_tempo
    FROM Historia_Incydentow
    GROUP BY
        pseudo
    ORDER BY
        srednie_tempo DESC
)
SELECT 
    pseudo 
FROM SrednieTempa
WHERE
    ROWNUM = 1;


/*
28. Wypisz koty, które rywalizowały zarówno z KAZIO, jak i z DZIKI BILL.
*/
WITH RywalizacjaKazio AS (
    SELECT
        pseudo
    FROM Historia_Incydentow
    WHERE
        imie_wroga = 'KAZIO'
),
RywalizacjaDzikiBill AS (
    SELECT
        pseudo
    FROM Historia_Incydentow
    WHERE
        imie_wroga = 'DZIKI BILL'
)
SELECT DISTINCT
    rdb.pseudo
FROM RywalizacjaKazio rk
    INNER JOIN RywalizacjaDzikiBill rdb ON rdb.pseudo = rk.pseudo;

/*
29. Znajdź koty, które w co najmniej jednym incydencie miały:
– wynik = 'KOT'
– poziom agresji < 3
– czas trwania < 10
(idealne incydenty).
*/
WITH LiczbaWynikiKot AS (
    SELECT
        pseudo,
        COUNT(*) AS liczba_wyniki
    FROM Historia_Incydentow
    WHERE
        wynik = 'KOT'
    GROUP BY 
        pseudo
    HAVING
        liczba_wyniki > 0
),
LiczbaPoziomAgresji AS (
    SELECT
        pseudo,
        COUNT(*) AS liczba_poziomy
    FROM Historia_Incydentow
    WHERE
        poziom_agresji < 3
    GROUP BY
        pseudo
),
LiczbaCzasTrwania AS (
    SELECT
        pseudo,
        COUNT(*) AS liczba_czas
    FROM Historia_Incydentow
    WHERE
        czas_trwania_min < 10
    GROUP BY
        pseudo
)
SELECT
    *
FROM LiczbaWynikiKot lwk
    INNER JOIN LiczbaPoziomAgresji lpa ON lpa.pseudo = lwk.pseudo
    INNER JOIN LiczbaCzasTrwania lct ON lct.pseudo = lwk.pseudo;

/*
30. Wyświetl rok, w którym kot TYGRYS miał najwięcej incydentów.
*/
WITH LataIncydentowTygrysa AS (
    SELECT
        COUNT(pseudo) AS liczba,
        EXTRACT(YEAR FROM data_incydentu) AS rok
    FROM Historia_Incydentow
    WHERE
        pseudo = 'TYGRYS'
    GROUP BY
        rok
    ORDER BY
        liczba DESC
)
SELECT
    rok
FROM LataIncydentowTygrysa
WHERE
    ROWNUM = 1;

/*
31. Znajdź bandy, których koty:
– mają średnią agresję incydentów > 6
– a jednocześnie łączna liczba świadków > 10.
*/
WITH SrednieAgresje AS (
    SELECT
        pseudo,
        ROUND(AVG(poziom_agresji), 2) AS sredni_poziom
    FROM Historia_Incydentow
    GROUP BY
        pseudo
),
LiczbySwiadkow AS (
    SELECT
        pseudo,
        SUM(liczba_swiadkow) AS calk_licz_swiad
    FROM Historia_Incydentow
    GROUP BY
        pseudo
)
SELECT
    b.nazwa
FROM Bandy b
    INNER JOIN Kocury k ON k.nr_bandy = b.nr_bandy
    INNER JOIN SrednieAgresje sa ON sa.pseudo = k.pseudo
    INNER JOIN LiczbySwiadkow lsw ON lsw.pseudo = sa.pseudo
WHERE
    sa.sredni_poziom > 6
    AND
    lsw.calk_licz_swiad > 10;

/*
32. Dla każdego kota podaj trend agresji w kolejnych latach:
różnica: agresja_rok_n - agresja_rok_(n-1)
(funkcja analityczna LAG).
*/
WITH PoziomyAgresji AS (
    SELECT
        pseudo,
        ROUND(AVG(poziom_agresji), 2) AS poziom,
        EXTRACT(YEAR FROM data_incydentu) AS rok
    FROM Historia_Incydentow
    GROUP BY
        pseudo,
        EXTRACT(YEAR FROM data_incydentu)
    ORDER BY
        pseudo
)
SELECT 
    pseudo,
    poziom - poprzedni_rok AS roznica
FROM (
    SELECT
        pseudo,
        poziom,
        LAG(poziom, 1, 0) OVER (PARTITION BY rok ORDER BY pseudo) AS poprzedni_rok
    FROM PoziomyAgresji
    ORDER BY
        pseudo,
        poprzedni_rok
    );

/*
33. Podaj koty, których *średni poziom agresji w incydentach przegranych*
jest wyższy niż *średni poziom agresji w incydentach wygranych*.
*/
WITH IncydentyPrzegrane AS (
    SELECT
        pseudo,
        ROUND(AVG(poziom_agresji), 2) AS sredni_przegrane
    FROM Historia_Incydentow
    WHERE
        wynik = 'WROG'
    GROUP BY
        pseudo
),
IncydentyWygrane AS (
    SELECT
        pseudo,
        ROUND(AVG(poziom_agresji), 2) AS sredni_wygrane
    FROM Historia_Incydentow
    WHERE
        wynik = 'KOT'
    GROUP BY
        pseudo
)
SELECT 
    ip.pseudo,
    ip.sredni_przegrane,
    iw.sredni_wygrane
FROM IncydentyPrzegrane ip 
    INNER JOIN IncydentyWygrane iw ON iw.pseudo = ip.pseudo
WHERE
    ip.sredni_przegrane > iw.sredni_wygrane;

/*
34. Znajdź koty, które miały co najmniej 2 incydenty w tym samym dniu.
*/
SELECT
    pseudo,
    data_incydentu,
    COUNT(*) AS liczba_incydentow_dnia
FROM Historia_Incydentow
GROUP BY
    pseudo,
    data_incydentu;

/*
35. Dla każdego kota policz łączny czas rekonwalescencji:
BRAK = 0, SZYBKA = 3, DLUGA = 14.
*/
SELECT
    pseudo,
    SUM(
        DECODE(
            rekonwalescencja,
            'BRAK', 0,
            'SZYBKA', 3,
            'DLUGA', 14
        )
    ) AS laczny_czas
FROM Historia_Incydentow
GROUP BY
    pseudo;

/*
36. Znajdź wszystkie incydenty, które odbyły się poza terenem bandy kota.
*/
SELECT
    hi.pseudo,
    hi.imie_wroga,
    hi.miejsce,
    k.nr_bandy,
    b.nr_bandy,
    b.teren
FROM Historia_Incydentow hi
    INNER JOIN Kocury k ON k.pseudo = hi.pseudo
    INNER JOIN Bandy b ON b.nr_bandy = k.nr_bandy
WHERE
    hi.miejsce != b.teren
    OR
    b.teren = 'CALOSC'
ORDER BY
    hi.pseudo;

/*
37. Wyświetl kota o najwyższej sumie strat w incydentach,
ale tylko z lat, w których miał minimum 5 incydentów.
*/
WITH IncydentyWRoku5 AS (
    SELECT
        pseudo,
        COUNT(EXTRACT(YEAR FROM data_incydentu)) AS liczba_incydentow
    FROM Historia_Incydentow
    GROUP BY
        pseudo,
        EXTRACT(YEAR FROM data_incydentu)
    HAVING
        liczba_incydentow >= 5
),
SumaStratWRoku AS (
    SELECT
        pseudo,
        SUM((straty_myszy)) AS suma_strat
    FROM Historia_Incydentow
    GROUP BY
        pseudo,
        EXTRACT(YEAR FROM data_incydentu)
)
SELECT
    *
FROM (
    SELECT DISTINCT
        sswr.*
    FROM SumaStratWRoku sswr
        INNER JOIN IncydentyWRoku5 iwr5 ON iwr5.pseudo = sswr.pseudo
    ORDER BY 
        suma_strat DESC
)
WHERE 
    ROWNUM = 1; 

/*
38. Wyświetl zestawienie:
kot – wróg – liczba walk – procent zwycięstw kota.
*/
WITH WygraneKota AS (
    SELECT
        pseudo,
        imie_wroga,
        COUNT(*) AS liczba_zwyciestw_kota
    FROM Historia_Incydentow
    WHERE
        wynik = 'KOT'
    GROUP BY
        pseudo,
        imie_wroga
    ORDER BY
        pseudo
)
SELECT
    hi.pseudo,
    hi.imie_wroga,
    COUNT(hi.pseudo) AS liczba_walk,
    ROUND(100 * wk.liczba_zwyciestw_kota / COUNT(hi.pseudo), 2) AS procent
FROM Historia_Incydentow hi
    INNER JOIN WygraneKota wk ON wk.pseudo = hi.pseudo
GROUP BY
    hi.pseudo, 
    hi.imie_wroga,
    wk.liczba_zwyciestw_kota;

/*
39. Znajdź walkę o największych łącznych stratach:
(straty_myszy × liczba_swiadkow).
*/
SELECT
    id_incydentu,
    pseudo,
    imie_wroga,
    data_incydentu,
    straty_myszy * liczba_swiadkow AS laczne_straty
FROM Historia_Incydentow
WHERE
    straty_myszy * liczba_swiadkow = (
        SELECT
            MAX(straty_myszy * liczba_swiadkow)
        FROM Historia_Incydentow
    );

/*
40. Zbuduj ranking kotów wg „punktów bitewnych”:
punkty = (wygrane × 3) + (remisy × 1) – (porażki × 2).
*/
WITH Wygrane AS (
    SELECT
        pseudo,
        COUNT(pseudo) AS punkty
    FROM Historia_Incydentow
    WHERE
        wynik = 'KOT'
    GROUP BY
        pseudo
),
Remisy AS (
    SELECT
        pseudo,
        COUNT(pseudo) AS punkty
    FROM Historia_Incydentow
    WHERE
        wynik = 'REMIS'
    GROUP BY
        pseudo
),
Przegrane AS (
        SELECT
        pseudo,
        COUNT(pseudo) AS punkty
    FROM Historia_Incydentow
    WHERE
        wynik = 'WROG'
    GROUP BY
        pseudo
),
PunktyBitewne AS (
    SELECT DISTINCT
        hi.pseudo AS pseudonim,
        NVL(w.punkty, 0) * 3 + NVL(re.punkty, 0) - NVL(p.punkty, 0) * 2 AS punkty_razem
    FROM Historia_Incydentow hi
        LEFT JOIN Wygrane w ON w.pseudo = hi.pseudo
        LEFT JOIN Remisy re ON re.pseudo = hi.pseudo
        LEFT JOIN Przegrane p ON p.pseudo = hi.pseudo
)
SELECT 
    pseudonim,
    punkty_razem,
    DENSE_RANK() OVER (ORDER BY punkty_razem DESC) AS ranking
FROM PunktyBitewne;

/*
1. PIVOT – liczba incydentów wg wyniku (KOT/WROG/REMIS) dla każdego kota
*/
SELECT
    pseudo,
    KOT,
    WROG,
    REMIS
FROM (
    SELECT
        pseudo,
        wynik
    FROM Historia_Incydentow
) src
PIVOT (
    COUNT(*)
    FOR wynik IN ('KOT' AS KOT, 'WROG' AS WROG, 'REMIS' AS REMIS)
) pvt
ORDER BY 
    pseudo;

/*
3. PIVOT – suma strat myszy wg terenu (POLE, SAD, GORKA, ZAGRODA)
*/
SELECT
    POLE,
    SAD,
    GORKA,
    ZAGRODA
FROM (
    SELECT
        miejsce,
        straty_myszy
    FROM Historia_Incydentow
)
PIVOT (
    SUM(straty_myszy)
    FOR miejsce IN ('POLE' AS POLE, 'SAD' AS SAD, 'GORKA' AS GORKA, 'ZAGRODA' AS ZAGRODA)
) pvt;

/*
6. Ranking kotów wg liczby incydentów (z funkcją analityczną)
*/
WITH LiczbyIncydentow AS (
    SELECT
        pseudo,
        COUNT(*) OVER (PARTITION BY pseudo) AS liczba
    FROM Historia_Incydentow
)
SELECT DISTINCT
    pseudo,
    liczba,
    DENSE_RANK() OVER (ORDER BY liczba DESC) AS ranking
FROM LiczbyIncydentow;

/*
10. Rolling sum — suma strat z ostatnich 3 incydentów kota
*/
SELECT
    pseudo,
    SUM(straty_myszy) OVER (
        PARTITION BY pseudo 
        ORDER BY data_incydentu 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_sum
FROM Historia_Incydentow
ORDER BY
    pseudo,
    data_incydentu;

/*
13. Pokaż wszystkich podwładnych dowolnego kota (parametr), z poziomem LEVEL
*/
WITH Hierarchia (pseudo, szef, lvl) AS (
    -- część bazowa
    SELECT
        pseudo,
        szef,
        1 AS lvl
    FROM Kocury
    WHERE
        pseudo = &input_pseudo

    UNION ALL

    -- część rekursywna: idziemy do góry po przełożonych
    SELECT
        k.pseudo,
        k.szef,
        h.lvl + 1 AS lvl
    FROM Kocury k
    JOIN Hierarchia h ON k.pseudo = h.szef
)
SELECT *
FROM Hierarchia;

/*
18. Znajdź koty będące jedynakami — jedyni podwładni swojego szefa
*/

