-- Personalization: score live bookings and assign a next-best action per segment
CREATE OR REPLACE TABLE `tls_demo.next_best_action` AS
SELECT
  p.segment, p.channel_group, p.lead_time, p.adr,
  prob.prob                                                  AS cancel_risk,
  CASE
    WHEN prob.prob >= 0.6 AND p.channel_group = 'Agent'      THEN 'Agent outreach: confirm trip, offer flexible rebooking'
    WHEN prob.prob >= 0.6                                    THEN 'Digital nudge: reminder + flexible change option'
    WHEN p.segment = 'Family'                                THEN 'Offer family room / kids meal bundle'
    WHEN p.segment = 'Business'                              THEN 'Offer late checkout / workspace upgrade'
    WHEN p.segment = 'Early Planner'                         THEN 'Offer pre-trip experiences'
    ELSE 'Standard confirmation'
  END AS next_best_action
FROM ML.PREDICT(MODEL `tls_demo.cancel_model`,
       (SELECT * FROM `tls_demo.traveler_segments`)) AS p,
     UNNEST(p.predicted_is_canceled_probs) AS prob
WHERE prob.label = 1;

-- Share of high-risk bookings routed to each action (headline number)
SELECT next_best_action, COUNT(*) AS bookings,
       ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM `tls_demo.next_best_action`
GROUP BY next_best_action ORDER BY bookings DESC;
