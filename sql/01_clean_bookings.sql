-- ELT step: raw CSV (loaded as all-STRING or autodetect) -> typed, cleaned table
CREATE OR REPLACE TABLE `tls_demo.bookings_clean` AS
SELECT
  hotel,
  SAFE_CAST(is_canceled AS INT64)                         AS is_canceled,
  SAFE_CAST(lead_time AS INT64)                           AS lead_time,
  SAFE_CAST(arrival_date_year AS INT64)                   AS arrival_year,
  arrival_date_month                                      AS arrival_month,
  SAFE_CAST(stays_in_weekend_nights AS INT64)             AS weekend_nights,
  SAFE_CAST(stays_in_week_nights AS INT64)                AS week_nights,
  SAFE_CAST(adults AS INT64)                              AS adults,
  IFNULL(SAFE_CAST(children AS INT64), 0)                 AS children,   -- 'NA' -> 0
  IFNULL(SAFE_CAST(babies AS INT64), 0)                   AS babies,
  meal,
  NULLIF(country, 'NULL')                                 AS country,
  market_segment,
  distribution_channel,                                   -- TA/TO (agent), Direct, Corporate, GDS
  SAFE_CAST(is_repeated_guest AS INT64)                   AS is_repeated_guest,
  SAFE_CAST(previous_cancellations AS INT64)              AS previous_cancellations,
  reserved_room_type,
  assigned_room_type,
  SAFE_CAST(booking_changes AS INT64)                     AS booking_changes,
  deposit_type,
  customer_type,
  SAFE_CAST(adr AS FLOAT64)                               AS adr,        -- average daily rate
  SAFE_CAST(total_of_special_requests AS INT64)           AS special_requests
FROM `tls_demo.hotel_bookings_raw`
WHERE SAFE_CAST(adults AS INT64) + IFNULL(SAFE_CAST(children AS INT64),0) + IFNULL(SAFE_CAST(babies AS INT64),0) > 0  -- drop zero-guest rows
  AND SAFE_CAST(adr AS FLOAT64) BETWEEN 0 AND 1000;                                                                  -- drop rate outliers

-- Data quality check: record these counts for the README
SELECT COUNT(*) AS clean_rows FROM `tls_demo.bookings_clean`;
SELECT COUNT(*) AS raw_rows   FROM `tls_demo.hotel_bookings_raw`;
