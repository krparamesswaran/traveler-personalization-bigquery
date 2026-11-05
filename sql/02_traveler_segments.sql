-- Rule-based traveler segments for personalization
CREATE OR REPLACE TABLE `tls_demo.traveler_segments` AS
SELECT
  *,
  CASE
    WHEN children + babies > 0                                    THEN 'Family'
    WHEN customer_type = 'Transient' AND weekend_nights = 0
         AND week_nights BETWEEN 1 AND 4 AND adults = 1           THEN 'Business'
    WHEN lead_time > 120                                          THEN 'Early Planner'
    WHEN lead_time <= 7                                           THEN 'Last Minute'
    ELSE 'Leisure'
  END AS segment,
  CASE WHEN distribution_channel = 'TA/TO' THEN 'Agent' ELSE 'Digital/Direct' END AS channel_group
FROM `tls_demo.bookings_clean`;

-- Segment KPIs: size, cancellation rate, spend, special requests, by channel
SELECT
  segment, channel_group,
  COUNT(*)                                   AS bookings,
  ROUND(AVG(is_canceled) * 100, 1)           AS cancel_rate_pct,
  ROUND(AVG(adr), 2)                         AS avg_daily_rate,
  ROUND(AVG(special_requests), 2)            AS avg_special_requests,
  ROUND(AVG(is_repeated_guest) * 100, 1)     AS repeat_guest_pct
FROM `tls_demo.traveler_segments`
GROUP BY segment, channel_group
ORDER BY bookings DESC;
