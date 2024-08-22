/*
Tutaj zdefiniuj schemę `reporting`
*/
-- Tworzenie schematu reporting
DROP SCHEMA IF EXISTS reporting CASCADE;
CREATE SCHEMA IF NOT EXISTS reporting;
/*
Tutaj napisz definicję widoku reporting.flight, która:
- będzie usuwać dane o lotach anulowanych `cancelled = 0`
- będzie zawierać kolumnę `is_delayed`, zgodnie z wcześniejszą definicją tj. `is_delayed = 1 if dep_delay_new > 0 else 0` (zaimplementowana w SQL)

Wskazówka:
- SQL - analiza danych > Dzień 4 Proceduralny SQL > Wyrażenia warunkowe
- SQL - analiza danych > Przygotowanie do zjazdu 2 > Widoki
*/
-- Definicja widoku reporting.flight
DROP VIEW IF EXISTS reporting.flight;
CREATE VIEW reporting.flight AS
SELECT
    id,
    year,
    month,
    day_of_month,
    day_of_week,
    op_unique_carrier,
    tail_num,
    op_carrier_fl_num,
    origin_airport_id,
    dest_airport_id,
    crs_dep_time,
    dep_time,
    dep_delay_new,
    dep_time_blk,
    crs_arr_time,
    arr_time,
    arr_delay_new,
    arr_time_blk,
    cancelled,
    crs_elapsed_time,
    actual_elapsed_time,
    distance,
    distance_group,
    CASE
        WHEN dep_delay_new > 0 THEN 1
        ELSE 0
    END AS is_delayed
FROM
    flight
WHERE
    cancelled = 0;
/*
Tutaj napisz definicję widoku reporting.top_reliability_roads, która będzie zawierała następujące kolumny:
- `origin_airport_id`,
- `origin_airport_name`,
- `dest_airport_id`,
- `dest_airport_name`,
- `year`,
- `cnt` - jako liczba wykonananych lotów na danej trasie,
- `reliability` - jako odsetek opóźnień na danej trasie,
- `nb` - numerowane od 1, 2, 3 według kolumny `reliability`. W przypadku takich samych wartości powino zwrócić 1, 2, 2, 3... 
Pamiętaj o tym, że w wyniku powinny pojawić się takie trasy, na których odbyło się ponad 10000 lotów.

Wskazówka:
- SQL - analiza danych > Dzień 2 Relacje oraz JOIN > JOIN
- SQL - analiza danych > Dzień 3 - Analiza danych > Grupowanie
- SQL - analiza danych > Dzień 1 Podstawy SQL > Aliasowanie
- SQL - analiza danych > Dzień 1 Podstawy SQL > Podzapytania
*/
-- Definicja widoku reporting.top_reliability_roads
DROP VIEW IF EXISTS reporting.top_reliability_roads;
CREATE VIEW reporting.top_reliability_roads AS
WITH cte as (
SELECT
    f.origin_airport_id,
    f.dest_airport_id,
    f.year,
    count(1) as flights_amount,
    avg(f.is_delayed)as reliability
FROM
    reporting.flight as f
GROUP BY
    f.origin_airport_id,
    f.dest_airport_id,
    f.year
HAVING
    COUNT(1) > 10000
)
SELECT
    c.origin_airport_id,
    al1.name as origin_airport_name,

    c.dest_airport_id,
    al2.name as dest_airport_name,

    c.year,
    c.flights_amount,
    c.reliability,

    DENSE_RANK() OVER (ORDER BY c.reliability DESC) as nb
FROM
        cte as c
    INNER JOIN
        airport_list as al1 on c.origin_airport_id = al1.origin_airport_id
    INNER JOIN
        airport_list as al2 on c.dest_airport_id = al2.origin_airport_id;
/*
Tutaj napisz definicję widoku reporting.year_to_year_comparision, która będzie zawierał następujące kolumny:
- `year`
- `month`,
- `flights_amount`
- `reliability`
*/
DROP VIEW IF EXISTS reporting.year_to_year_comparision;
CREATE VIEW reporting.year_to_year_comparision AS
SELECT
    year,
    month,
    COUNT(1) AS flights_amount,
    AVG(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) AS reliability
FROM
    flight
GROUP BY
    year,
    month;
/*
Tutaj napisz definicję widoku reporting.day_to_day_comparision, który będzie zawierał następujące kolumny:
- `year`
- `day_of_week`
- `flights_amount`
*/
DROP VIEW IF EXISTS reporting.day_to_day_comparision;
CREATE VIEW reporting.day_to_day_comparision AS
SELECT
    year,
    day_of_week,
    COUNT(1) AS flights_amount,
    AVG(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) AS reliability
FROM
    flight
GROUP BY
    year,
    day_of_week;
/*
Tutaj napisz definicję widoku reporting.day_by_day_reliability, ktory będzie zawierał następujące kolumny:
- `date` jako złożenie kolumn `year`, `month`, `day`, powinna być typu `date`
- `reliability` jako odsetek opóźnień danego dnia

Wskazówki:
- formaty dat w postgresql: [klik](https://www.postgresql.org/docs/13/functions-formatting.html),
- jeśli chcesz dodać zera na początek liczby np. `1` > `01`, posłuż się metodą `LPAD`: [przykład](https://stackoverflow.com/questions/26379446/padding-zeros-to-the-left-in-postgresql),
- do konwertowania ciągu znaków na datę najwygodniej w Postgres użyć `to_date`: [przykład](https://www.postgresqltutorial.com/postgresql-date-functions/postgresql-to_date/)
- do złączenia kilku kolumn / wartości typu string, używa się operatora `||`, przykładowo: SELECT 'a' || 'b' as example

Uwaga: Nie dodawaj tutaj na końcu srednika - przy używaniu split, pojawi się pusta kwerenda, co będzie skutkowało późniejszym błędem przy próbie wykonania skryptu z poziomu notatnika.
*/
DROP VIEW IF EXISTS reporting.day_by_day_reliability;
CREATE VIEW reporting.day_by_day_reliability AS
SELECT
    TO_DATE(year::text || '-' || LPAD(month::text, 2, '0') || '-' || LPAD(day_of_month::text, 2, '0'), 'YYYY-MM-DD') AS date,
    AVG(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) AS reliability
FROM
    flight
GROUP BY
    year,
    month,
    day_of_month