-- Create a clean table with a well-defined structure
CREATE TABLE IF NOT EXISTS shipping_data_clean (
    id INTEGER,
    updated TEXT,  -- Standardized format: YYYY-MM-DD HH:MM:SS
    ship TEXT,
    imo INTEGER,
    lat REAL,
    long REAL,
    sog REAL,
    cog INTEGER,
    hdg INTEGER,
    depPort TEXT,
    etdSchedule TEXT, -- Standardized
    etd TEXT, -- Standardized
    atd TEXT, -- Standardized
    arrPort TEXT,
    etaSchedule TEXT, -- Standardized
    eta TEXT, -- Standardized
    ata TEXT, -- Standardized
    PRIMARY KEY (id, updated) -- Composite primary key to help avoid duplicates
);


-- Populate the clean table with standardized data and handle missing values

INSERT INTO shipping_data_clean (id, updated, ship, imo, lat, long, sog, cog, hdg,
                                 depPort, etdSchedule, etd, atd, arrPort, etaSchedule, eta, ata)
SELECT
    id,
    -- 1. Standardize the main 'updated' timestamp
    CASE
        WHEN instr(updated, '/') > 0 THEN substr(updated, 7, 4) || '-' || substr(updated, 4, 2) || '-' || substr(updated, 1, 2) || ' ' || substr(updated, 12)
        ELSE updated
    END as updated_std,
    ship,
    imo,
    lat,
    long,
    sog,
    cog,
    hdg,
    -- 2. Clean Port Names: Keep them as is, but you could add a lookup here
    depPort,
    -- 3. Standardize Date/Time fields: etdSchedule, etd, atd, etaSchedule, eta, ata
    CASE
        WHEN etdSchedule IS NOT NULL AND etdSchedule != '' AND instr(etdSchedule, '/') > 0 THEN substr(etdSchedule, 7, 4) || '-' || substr(etdSchedule, 4, 2) || '-' || substr(etdSchedule, 1, 2) || ' ' || substr(etdSchedule, 12)
        WHEN etdSchedule IS NOT NULL AND etdSchedule != '' THEN etdSchedule
        ELSE NULL
    END as etdSchedule_std,
    CASE
        WHEN etd IS NOT NULL AND etd != '' AND instr(etd, '/') > 0 THEN substr(etd, 7, 4) || '-' || substr(etd, 4, 2) || '-' || substr(etd, 1, 2) || ' ' || substr(etd, 12)
        WHEN etd IS NOT NULL AND etd != '' THEN etd
        ELSE NULL
    END as etd_std,
    -- 4. Handle NULL/Empty strings: atd is a good example, often empty. We'll keep it as NULL.
    CASE
        WHEN atd IS NOT NULL AND atd != '' AND instr(atd, '/') > 0 THEN substr(atd, 7, 4) || '-' || substr(atd, 4, 2) || '-' || substr(atd, 1, 2) || ' ' || substr(atd, 12)
        WHEN atd IS NOT NULL AND atd != '' THEN atd
        ELSE NULL
    END as atd_std,
    arrPort,
    CASE
        WHEN etaSchedule IS NOT NULL AND etaSchedule != '' AND instr(etaSchedule, '/') > 0 THEN substr(etaSchedule, 7, 4) || '-' || substr(etaSchedule, 4, 2) || '-' || substr(etaSchedule, 1, 2) || ' ' || substr(etaSchedule, 12)
        WHEN etaSchedule IS NOT NULL AND etaSchedule != '' THEN etaSchedule
        ELSE NULL
    END as etaSchedule_std,
    CASE
        WHEN eta IS NOT NULL AND eta != '' AND instr(eta, '/') > 0 THEN substr(eta, 7, 4) || '-' || substr(eta, 4, 2) || '-' || substr(eta, 1, 2) || ' ' || substr(eta, 12)
        WHEN eta IS NOT NULL AND eta != '' THEN eta
        ELSE NULL
    END as eta_std,
    CASE
        WHEN ata IS NOT NULL AND ata != '' AND instr(ata, '/') > 0 THEN substr(ata, 7, 4) || '-' || substr(ata, 4, 2) || '-' || substr(ata, 1, 2) || ' ' || substr(ata, 12)
        WHEN ata IS NOT NULL AND ata != '' THEN ata
        ELSE NULL
    END as ata_std
FROM "Container ship data collection.csv" csdcc ;


-- Count of rows with departure info
SELECT 
	'dep_port n atd' AS column_name,
	COUNT(*) FROM shipping_data_clean 
WHERE depPort IS NOT NULL AND depPort != '' 
  AND atd IS NOT NULL AND atd != ''
UNION ALL
-- Count of rows with arrival info
SELECT 
	'arr_port n ata',
	COUNT(*) FROM shipping_data_clean 
WHERE arrPort IS NOT NULL AND arrPort != '' 
  AND ata IS NOT NULL AND ata != ''
UNION ALL
-- Count of rows with both (complete voyage)
SELECT 
	'all',
	COUNT(*) FROM shipping_data_clean 
WHERE depPort IS NOT NULL AND arrPort IS NOT NULL 
  AND atd IS NOT NULL AND ata IS NOT NULL;

column_name   |COUNT(*)|
--------------+--------+
dep_port n atd|  816945|
arr_port n ata|  322212|
all           |  319441|



-- Which departure ports have the highest missing arrival rate?
SELECT 
    depPort,
    COUNT(*) AS total_departures,
    SUM(CASE WHEN arrPort IS NOT NULL AND ata IS NOT NULL THEN 1 ELSE 0 END) AS with_arrival,
    ROUND(100.0 * SUM(CASE WHEN arrPort IS NOT NULL AND ata IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_with_arrival
FROM shipping_data_clean
WHERE depPort IS NOT NULL AND depPort != ''
GROUP BY depPort
ORDER BY pct_with_arrival ASC;

depPort|total_departures|with_arrival|pct_with_arrival|
-------+----------------+------------+----------------+
FIHEL  |          418490|      163418|           39.05|
EETLL  |          405182|      158794|           39.19|

--for shios
SELECT 
    ship,
    COUNT(*) AS total_departures,
    SUM(CASE WHEN arrPort IS NOT NULL AND ata IS NOT NULL THEN 1 ELSE 0 END) AS with_arrival,
    ROUND(100.0 * SUM(CASE WHEN arrPort IS NOT NULL AND ata IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_with_arrival
FROM shipping_data_clean
WHERE depPort IS NOT NULL AND depPort != ''
GROUP BY ship
ORDER BY pct_with_arrival ASC;

ship     |total_departures|with_arrival|pct_with_arrival|
---------+----------------+------------+----------------+
FINLANDIA|            4931|           0|             0.0|
MEGAStar |            5029|           0|             0.0|
Finlandia|          240477|       89774|           37.33|
Europa   |           86030|       34181|           39.73|
Star     |          234102|       94295|           40.28|
Megastar |          253103|      103962|           41.07|



--Query A: Basic Statistics
-- 1. Total number of records in the clean table
SELECT 
	'ship data clean' AS column_name,
	COUNT(*) AS Total_Records 
FROM shipping_data_clean
UNION ALL
SELECT 
	'cont ship data collec',
	COUNT(*) AS Total_Records 
FROM "Container ship data collection.csv" csdcc ;

column_name          |Total_Records|
---------------------+-------------+
ship data clean      |       823672|
cont ship data collec|       823672|

--Note: There is no duplicate in this data, after delete duplicate 
-- total records were same.
       

-- 2. Number of records per ship
SELECT
    ship,
    COUNT(*) AS Record_Count
FROM shipping_data_clean
GROUP BY ship;

ship     |Record_Count|
---------+------------+
Europa   |       86030|
FINLANDIA|        4931|
Finlandia|      240477|
MEGAStar |        5029|
Megastar |      253103|
Star     |      234102|


-- 3. Check for missing critical data (e.g., ATD, ATA)
SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN atd IS NULL OR atd = '' THEN 1 ELSE 0 END) AS Missing_ATD,
    SUM(CASE WHEN ata IS NULL OR ata = '' THEN 1 ELSE 0 END) AS Missing_ATA,
    ROUND(SUM(CASE WHEN atd IS NULL OR atd = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Pct_Missing_ATD,
    ROUND(SUM(CASE WHEN ata IS NULL OR ata = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Pct_Missing_ATA
FROM shipping_data_clean;

Total_Records|Missing_ATD|Missing_ATA|Pct_Missing_ATD|Pct_Missing_ATA|
-------------+-----------+-----------+---------------+---------------+
       823672|       6727|     501460|           0.82|          60.88|
       
       
       
Query B: Deep Analysis of Schedule Adherence

-- Calculate Departure Delay in Hours
SELECT
    ship,
    COUNT(*) as Total_Depart_With_Data,
    -- Average delay (positive means late)
    ROUND(AVG((julianday(atd) - julianday(etd)) * 24), 2) AS Avg_Depart_Delay_Hours,
    -- Maximum and Minimum delays
    ROUND(MAX((julianday(atd) - julianday(etd)) * 24), 2) AS Max_Depart_Delay_Hours,
    ROUND(MIN((julianday(atd) - julianday(etd)) * 24), 2) AS Min_Depart_Delay_Hours,
    -- Percentage of on-time departures (delay <= 0)
    ROUND(SUM(CASE WHEN (julianday(atd) - julianday(etd)) * 24 <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Pct_On_Time_Depart
FROM shipping_data_clean
WHERE atd IS NOT NULL AND etd IS NOT NULL AND atd != '' AND etd != ''
GROUP BY ship;

ship     |Total_Depart_With_Data|Avg_Depart_Delay_Hours|Max_Depart_Delay_Hours|Min_Depart_Delay_Hours|Pct_On_Time_Depart|
---------+----------------------+----------------------+----------------------+----------------------+------------------+
Europa   |                 85379|                 -0.26|                  0.51|                 -42.4|             10.22|
FINLANDIA|                  4894|                 -9.56|                  0.14|                -44.35|             57.29|
Finlandia|                238605|                 -0.11|                  2.01|                 -6.16|             61.51|
MEGAStar |                  4991|                 -9.07|                 -0.06|                -44.18|             100.0|
Megastar |                250971|                 -0.22|                   2.0|                -44.18|             97.38|
Star     |                232105|                 -0.38|                  2.15|                -44.16|             98.43|


Query C: Voyage Performance (Travel Time)

-- Calculate Voyage Duration
WITH voyage_durations AS (
    SELECT
        id,
        ship,
        depPort,
        arrPort,
        atd,
        ata,
        -- Calculate travel time in hours between departure and arrival
        ROUND((julianday(ata) - julianday(atd)) * 24, 2) AS travel_time_hours
    FROM shipping_data_clean
    WHERE depPort IS NOT NULL AND depPort != ''
      AND arrPort IS NOT NULL AND arrPort != ''
      AND atd IS NOT NULL AND atd != ''
      AND ata IS NOT NULL AND ata != ''
)
SELECT
    ship,
    depPort,
    arrPort,
    COUNT(*) AS Number_Of_Voyages,
    ROUND(AVG(travel_time_hours), 2) AS Avg_Travel_Time_Hours,
    ROUND(MIN(travel_time_hours), 2) AS Min_Travel_Time_Hours,
    ROUND(MAX(travel_time_hours), 2) AS Max_Travel_Time_Hours
FROM voyage_durations
GROUP BY ship, depPort, arrPort;

ship     |depPort|arrPort|Number_Of_Voyages|Avg_Travel_Time_Hours|Min_Travel_Time_Hours|Max_Travel_Time_Hours|
---------+-------+-------+-----------------+---------------------+---------------------+---------------------+
Europa   |EETLL  |FIHEL  |            13161|              1170.47|             -7748.97|              7756.41|
Europa   |FIHEL  |EETLL  |            20747|              1281.82|             -6332.94|               7755.5|
Finlandia|EETLL  |FIHEL  |            45863|              -309.31|             -7749.95|              7035.48|
Finlandia|FIHEL  |EETLL  |            43167|              -258.88|             -7750.05|               7034.5|
Megastar |EETLL  |FIHEL  |            52561|               464.52|             -7750.04|              7755.32|
Megastar |FIHEL  |EETLL  |            50486|               427.13|              -7750.0|              7754.36|
Star     |EETLL  |FIHEL  |            45834|              -153.02|             -7750.05|              7035.22|
Star     |FIHEL  |EETLL  |            47622|               -89.17|             -7750.04|              7034.41|



-- Create a view with enriched columns for analysis
CREATE Table vw_shipping_analysis AS
SELECT
    id,
    ship,
    imo,
    updated,
    lat,
    long,
    sog,
    cog,
    hdg,
    depPort,
    arrPort,
    -- Standardised timestamps
    etdSchedule,
    etd,
    atd,
    etaSchedule,
    eta,
    ata,
    -- 1. Travel time in hours (ATA - ATD)
    ROUND((julianday(ata) - julianday(atd)) * 24, 2) AS travel_time_hours,
    -- 2. Departure delay in hours (ATD - ETD)
    ROUND((julianday(atd) - julianday(etd)) * 24, 2) AS departure_delay_hours,
    -- 3. Arrival delay in hours (ATA - ETA)
    ROUND((julianday(ata) - julianday(eta)) * 24, 2) AS arrival_delay_hours,
    -- 4. Time from scheduled departure to actual departure (for on-time %)
    CASE 
        WHEN etd IS NOT NULL AND atd IS NOT NULL 
             AND (julianday(atd) - julianday(etd)) * 24 <= 0 
        THEN 'on time' ELSE 'late departure' 
    END AS departed_on_time,
    -- 5. Time from scheduled arrival to actual arrival
    CASE 
        WHEN eta IS NOT NULL AND ata IS NOT NULL 
             AND (julianday(ata) - julianday(eta)) * 24 <= 0 
        THEN 'on time' ELSE 'late arrival'
    END AS arrived_on_time,
    -- 6. Flag for complete voyage (both departure and arrival data)
    CASE 
        WHEN depPort IS NOT NULL AND arrPort IS NOT NULL 
             AND atd IS NOT NULL AND ata IS NOT NULL 
        THEN 'complete' ELSE 'incomplete' 
    END AS has_complete_voyage
FROM shipping_data_clean;

id  |ship    |imo    |updated         |lat    |long   |sog |cog|hdg|depPort|arrPort|etdSchedule     |etd             |atd                |etaSchedule     |eta             |ata             |travel_time_hours|departure_delay_hours|arrival_delay_hours|departed_on_time|arrived_on_time|has_complete_voyage
----+--------+-------+----------------+-------+-------+----+---+---+-------+-------+----------------+----------------+-------------------+----------------+----------------+----------------+-----------------+---------------------+-------------------+----------------+---------------+-------------------
4136|Megastar|9773064|2018-04-05 19:18|60.1469|24.9135| 6.3|219|216|FIHEL  |EETLL  |2018-04-05 19:30|2018-04-07 15:29|2018-04-05 19:18:20|2018-04-05 21:30|2018-05-04 21:25|2018-05-04 21:23|           698.08|               -44.18|              -0.03|on time         |on time        |complete           
4137|Megastar|9773064|2018-04-05 19:19|60.1445|  24.91|11.6|217|217|FIHEL  |EETLL  |2018-04-05 19:30|2018-04-07 15:29|2018-04-05 19:18:20|2018-04-05 21:30|2018-05-04 21:25|2018-05-04 21:29|           698.18|               -44.18|               0.07|on time         |late arrival   |complete           
4138|Megastar|9773064|2018-04-05 19:20|60.1412|24.9061|14.2|198|199|FIHEL  |EETLL  |2018-04-05 19:30|2018-04-07 15:29|2018-04-05 19:18:20|2018-04-05 21:30|2018-05-04 21:25|2018-05-04 21:30|           698.19|               -44.18|               0.08|on time         |late arrival   |complete           
4139|Star    |9364722|2018-04-05 19:21|59.4462|24.7726| 3.7| 17|159|EETLL  |FIHEL  |2018-04-05 19:30|2018-04-07 15:25|2018-04-05 19:21:17|2018-04-05 21:30|2018-05-04 21:26|2018-05-04 21:46|           698.41|               -44.06|               0.33|on time         |late arrival   |complete           
4140|Megastar|9773064|2018-04-05 19:22|60.1344|24.9056|15.9|179|179|FIHEL  |EETLL  |2018-04-05 19:30|2018-04-07 15:29|2018-04-05 19:18:20|2018-04-05 21:30|2018-05-04 21:25|2018-05-04 21:32|           698.23|               -44.18|               0.12|on time         |late arrival   |complete           



SELECT * FROM vw_shipping_analysis vsa 
Limit 1000;





