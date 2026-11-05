# Traveler Personalization Insights on BigQuery

Segments ~119K hotel bookings into traveler types, predicts cancellation risk with BigQuery ML,
and assigns a next-best action per traveler across agent and digital channels.

Stack: Google BigQuery (sandbox), BigQuery ML, SQL, Looker Studio

## Steps
1. Dataset: Kaggle "Hotel Booking Demand" (hotel_bookings.csv).
2. BigQuery sandbox (free, no card): create dataset `tls_demo`, load CSV as `hotel_bookings_raw`
   (Schema: auto-detect; if a column fails, load all columns as STRING; the SQL casts safely).
3. Run sql/01 -> 04 in order.
4. Looker Studio: connect `tls_demo.traveler_segments` and `tls_demo.next_best_action`;
   build tiles for bookings, cancel rate, ADR by segment and channel.

## Results
- Rows: 119,390 raw, 119,208 after cleaning (182 zero-guest or outlier-rate rows removed)
- Segments: Family, Business, Early Planner, Last Minute, Leisure, split by Agent vs Digital/Direct channel
- Cancellation model (BigQuery ML logistic regression, 80/20 split):
  ROC AUC 0.82 | precision 0.87 | recall 0.47 | accuracy 0.78 | F1 0.61
- Top cancellation drivers: deposit type, special requests, lead time, market segment, customer type
- High-risk bookings (cancel probability >= 0.6): 17,404 (14.6% of all bookings)
- 94.6% of high-risk bookings came through travel agents (TA/TO), so agent outreach is the main lever

## Next-best action mix
| Action | Bookings | Share |
|---|---|---|
| Standard confirmation | 61,182 | 51.3% |
| Offer pre-trip experiences | 25,616 | 21.5% |
| Agent outreach: confirm trip, offer flexible rebooking | 16,471 | 13.8% |
| Offer family room / kids meal bundle | 8,438 | 7.1% |
| Offer late checkout / workspace upgrade | 6,568 | 5.5% |
| Digital nudge: reminder + flexible change option | 933 | 0.8% |

## Trade-off
The model is precise but conservative (87% precision, 47% recall): flagged bookings are usually real
cancellations, but about half of cancellations are missed. Lowering the 0.6 threshold would catch more
at the cost of more unnecessary outreach; the right threshold depends on outreach cost per booking.

Data: Hotel Booking Demand (Antonio, Almeida and Nunes, 2019), via Kaggle.
