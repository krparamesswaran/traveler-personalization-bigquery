-- BigQuery ML: predict cancellation risk (logistic regression)
CREATE OR REPLACE MODEL `tls_demo.cancel_model`
OPTIONS (model_type = 'logistic_reg', input_label_cols = ['is_canceled'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         enable_global_explain = TRUE) AS
SELECT
  is_canceled, lead_time, weekend_nights, week_nights, adults, children,
  market_segment, distribution_channel, is_repeated_guest, previous_cancellations,
  booking_changes, deposit_type, customer_type, adr, special_requests, hotel
FROM `tls_demo.bookings_clean`;

-- Record precision, recall, accuracy, roc_auc for the README and resume
SELECT * FROM ML.EVALUATE(MODEL `tls_demo.cancel_model`);

-- Which features drive cancellations (use for the "insight" line)
SELECT * FROM ML.GLOBAL_EXPLAIN(MODEL `tls_demo.cancel_model`);
