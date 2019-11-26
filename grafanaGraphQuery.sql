SELECT
  unix_time as time,
  temperature as value,
  sensor_alias as metric
FROM
  events
ORDER BY
  unix_time ASC