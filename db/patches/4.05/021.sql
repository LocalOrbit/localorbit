INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('021', '45657971');

UPDATE  `timezones` SET  `offset_seconds` =  '-18000' WHERE  `timezones`.`tz_id` =1;
UPDATE  `timezones` SET  `offset_seconds` =  '-21600' WHERE  `timezones`.`tz_id` =2;
UPDATE  `timezones` SET  `offset_seconds` =  '-25200' WHERE  `timezones`.`tz_id` =3;
UPDATE  `timezones` SET  `offset_seconds` =  '-28800' WHERE  `timezones`.`tz_id` =4;
