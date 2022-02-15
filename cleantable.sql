--not code but if you have trouble importing the csvs, check out sqlite.

--CHECK incomplete ROWS
SELECT count(*) from bikedata WHERE start_station_name IS NULL ; 
SELECT count(*) FROM bikedata WHERE end_station_name IS NULL ; 
--given that there are 1.3million rows with Null for both, I decided not to remove them, since these rows do have lat and lng filled out properly.
--besides, i didnt see much relevancy for these two rows when visualising my findings.


--find out which ride_id are duplicates first & remove if any
select ride_id
from bikedata
GROUP BY ride_id
having count (ride_id)>1 ;
--fortunately, there are none!

CREATE TABLE IF NOT EXISTS cleaned AS
SELECT 
  strftime('%Y', started_at) as year,
  CASE CAST(strftime('%m', started_at) as INTEGER)	--get season
  when 03 then 'Spring'
  when 04 then 'Spring'
  when 05 then 'Spring'
  when 06 then 'Summer'
  when 07 then 'Summer'
  when 08 then 'Summer'
  when 09 then 'Autumn'
  when 10 then 'Autumn'
  when 11 then 'Autumn'
  when 12 then 'Winter'
  when 01 then 'Winter'
  when 02 then 'Winter'
  end AS Season,
  
  
  strftime('%m', started_at) as month,
  case cast (strftime('%w', started_at) as integer)		--get day
  when 0 then 'Sunday'
  when 1 then 'Monday'
  when 2 then 'Tuesday'
  when 3 then 'Wednesday'
  when 4 then 'Thursday'
  when 5 then 'Friday'
  else 'Saturday' end as Day,
  strftime('%H', started_at) as start_hour,
  strftime('%H', ended_at) as end_hour,
 ROUND((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24*60) AS RentalMinutes,
start_station_name,
end_station_name,

member_casual,
start_lat,
start_lng,
end_lat,
end_lng,
rideable_type,
started_at

FROM bikedata

WHERE RentalMinutes BETWEEN 1 AND 1440;  --remove overnight rentals since they are charged by the minute. This implies maybe some people lost the bike or something.
--either way, i didnt think these data were relevant to our business question. Negative RentalMinutes indicated faulty data, so i filtered it out.
--60854 rows were filtered out, which is not too much.