1.

SELECT
  PIL_PILOTNAME,
  ROUND((PIL_HIREDATE - PIL_BRTHDATE) / 365.25,2) AS AGE
FROM
  PILOTS
WHERE
  (PIL_HIREDATE - PIL_BRTHDATE) = (
    SELECT
      MAX(PIL_HIREDATE - PIL_BRTHDATE)
    FROM
      PILOTS
  );

2.

WITH pilot_flights AS (
  SELECT 
    pil_pilotname,
    pil_pilot_id,
    SUM(fl_distance) AS miles_flown
  FROM
    pilots
    JOIN departures ON pil_pilot_id = dep_pilot_id
    JOIN flight ON dep_flight_no = fl_flight_no
    JOIN ticket ON dep_flight_no = tic_flight_no AND dep_dep_date = tic_flight_date
  GROUP BY
    pil_pilotname,
    pil_pilot_id
)
SELECT 
  pilots.pil_pilotname AS "Pilot Name",
  COALESCE(pilot_flights.miles_flown, 0) AS "Miles Flown"
FROM
  pilots
  LEFT JOIN pilot_flights ON pilots.pil_pilot_id = pilot_flights.pil_pilot_id
ORDER BY
  pilots.pil_pilotname;

3.
SELECT
  REGEXP_SUBSTR(PIL_PILOTNAME, '(\w+),', 1, 1, NULL, 1) AS "Last Name",
  REGEXP_SUBSTR(PIL_PILOTNAME, ',\s+(\w+)', 1, 1, NULL, 1) || 
  CASE
    WHEN REGEXP_SUBSTR(PIL_PILOTNAME, '\s(\w)\.', 1, 1, NULL, 1) IS NOT NULL THEN ' ' || REGEXP_SUBSTR(PIL_PILOTNAME, '\s(\w)\.', 1, 1, NULL, 1) || '.'
    ELSE ''
  END AS "First Name"
FROM
  PILOTS;
  
4.


WITH state_average_pay AS (
  SELECT
    PIL_STATE,
    AVG(PIL_FLIGHT_PAY) AS avg_state_pay
  FROM
    PILOTS
  GROUP BY
    PIL_STATE
),
pilots_with_state_average AS (
  SELECT
    P.*,
    state_average_pay.avg_state_pay
  FROM
    PILOTS P
    JOIN state_average_pay ON P.PIL_STATE = state_average_pay.PIL_STATE
)
SELECT
  pilots_with_state_average.PIL_PILOTNAME,
  pilots_with_state_average.PIL_STATE,
  pilots_with_state_average.PIL_FLIGHT_PAY AS "Flight Pay",
  pilots_with_state_average.avg_state_pay AS "Average State Pay"
FROM
  pilots_with_state_average
WHERE
  pilots_with_state_average.PIL_FLIGHT_PAY < pilots_with_state_average.avg_state_pay
ORDER BY
  pilots_with_state_average.PIL_STATE;
  


5.
SELECT
  PIL_PILOTNAME,
  PIL_FLIGHT_PAY,
  ROUND((SYSDATE - PIL_BRTHDATE) / 365.25,2) AS "Age"
FROM
  PILOTS
WHERE
  ROUND((SYSDATE - PIL_BRTHDATE) / 365.25,2) < 55
ORDER BY
  "Age" DESC;
  
 6.
 SELECT
  f.fl_flight_no AS "Flight Number",
  f.fl_orig AS "Originating Airport",
  f.fl_dest AS "Destination Airport",
  TO_CHAR(f.fl_orig_time, 'hh24:mi') AS "Departure Time",
  TO_CHAR(f.fl_dest_time, 'hh24:mi') AS "Arrival Time"
FROM
  flight f
WHERE
  f.fl_flight_no NOT IN (
    SELECT
      fl_flight_no
    FROM
      flight
    WHERE
      TRUNC(fl_orig_time) = TO_DATE('17-MAY-2017', 'DD-MON-YY')
  )
ORDER BY "Flight Number";

7.
(SELECT
  f.fl_flight_no AS "Flight Number",
  f.fl_orig AS "Originating Airport",
  f.fl_dest AS "Destination Airport",
  TO_CHAR(f.fl_orig_time, 'hh24:mi') AS "Departure Time",
  TO_CHAR(f.fl_dest_time, 'hh24:mi') AS "Arrival Time"
FROM
  flight f)
MINUS
(SELECT
  f.fl_flight_no AS "Flight Number",
  f.fl_orig AS "Originating Airport",
  f.fl_dest AS "Destination Airport",
  TO_CHAR(f.fl_orig_time, 'hh24:mi') AS "Departure Time",
  TO_CHAR(f.fl_dest_time, 'hh24:mi') AS "Arrival Time"
FROM
  flight f
WHERE
  TRUNC(f.fl_orig_time) = TO_DATE('17-MAY-2017', 'DD-MON-YY'));


8.
SELECT
  p.pil_pilotname AS "Pilot Name"
FROM
  pilots p
WHERE
  p.pil_pilot_id NOT IN (
    SELECT
      d.dep_pilot_id
    FROM
      departures d
    WHERE
      TRUNC(d.dep_dep_date) BETWEEN TO_DATE('01-MAY-2017', 'DD-MON-YY') AND TO_DATE('31-MAY-2017', 'DD-MON-YY')
  );


9.
SELECT
  p.pil_pilotname AS "Pilot Name"
FROM
  pilots p
MINUS
SELECT
  p.pil_pilotname
FROM
  pilots p
  JOIN departures d ON p.pil_pilot_id = d.dep_pilot_id
WHERE
  TRUNC(d.dep_dep_date) BETWEEN TO_DATE('01-MAY-2017', 'DD-MON-YY') AND TO_DATE('31-MAY-2017', 'DD-MON-YY');

10.
SELECT
  SUBSTR(pas_name, INSTR(pas_name, ' ') + 1) AS "Last Name",
  COUNT(*) AS "Number of Passengers"
FROM
  passenger
GROUP BY
  SUBSTR(pas_name, INSTR(pas_name, ' ') + 1)
ORDER BY
  COUNT(*) DESC;