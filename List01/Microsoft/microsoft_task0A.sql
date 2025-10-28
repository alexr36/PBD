--------------------------------------------------------------------------------
-- TASK 0A
--------------------------------------------------------------------------------
CREATE TABLE Bandy (
    nr_bandy   INT         CONSTRAINT pk_bandy PRIMARY KEY,
    nazwa      VARCHAR(20) CONSTRAINT nn_bandy_nazwa NOT NULL,
    teren      VARCHAR(15) CONSTRAINT uk_bandy_teren UNIQUE,
    szef_bandy VARCHAR(15) CONSTRAINT uk_bandy_szef_bandy UNIQUE
);

CREATE TABLE Funkcje (
    funkcja   VARCHAR(10) CONSTRAINT pk_funkcje PRIMARY KEY,
    min_myszy INT         CONSTRAINT ck_funkcje_min_myszy CHECK (min_myszy > 5),
    max_myszy INT,
    CONSTRAINT ck_funkcje_max_myszy CHECK (max_myszy < 200 AND max_myszy >= min_myszy)
);

CREATE TABLE Wrogowie (
    imie_wroga       VARCHAR(15) CONSTRAINT pk_wrogowie PRIMARY KEY,
    stopien_wrogosci INT         CONSTRAINT ck_wrogowie_stopien_range CHECK (stopien_wrogosci BETWEEN 1 AND 10),
    gatunek          VARCHAR(15),
    lapowka          VARCHAR(20)
);

CREATE TABLE Kocury (
    imie            VARCHAR(15) CONSTRAINT nn_kocury_imie NOT NULL,
    plec            CHAR(1)     CONSTRAINT ck_kocury_plec_md CHECK (plec IN ('M', 'D')),
    pseudo          VARCHAR(15) CONSTRAINT pk_kocury PRIMARY KEY,
    funkcja         VARCHAR(10) CONSTRAINT fk_funkcje REFERENCES Funkcje(funkcja),
    szef            VARCHAR(15) CONSTRAINT fk_kocury_szef REFERENCES Kocury(pseudo),
    w_stadku_od     DATE DEFAULT GETDATE(),
    przydzial_myszy INT,
    myszy_extra     INT,
    nr_bandy        INT         CONSTRAINT fk_bandy REFERENCES Bandy(nr_bandy)
);

CREATE TABLE Wrogowie_kocurow (
    pseudo         VARCHAR(15) CONSTRAINT fk_kocury_pseudo REFERENCES Kocury(pseudo),
    imie_wroga     VARCHAR(15) CONSTRAINT fk_wrogowie REFERENCES Wrogowie(imie_wroga),
    data_incydentu DATE        CONSTRAINT nn_wrogowie_kocurow_data NOT NULL,
    opis_incydentu VARCHAR(50),
    CONSTRAINT pk_wrogowie_kocurow PRIMARY KEY (pseudo, imie_wroga)
);

-- Adding constraint to the szef_bandy field in Bandy table
ALTER TABLE Bandy 
ADD CONSTRAINT fk_kocury_szef_bandy FOREIGN KEY (szef_bandy) REFERENCES Kocury(pseudo);

