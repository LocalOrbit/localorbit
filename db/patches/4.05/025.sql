INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('025', '45895601');


UPDATE phrases
SET default_value = 'Stay Informed'
WHERE label = 'header:reg:newsletter-signup';

UPDATE domains
SET market_profile = REPLACE(market_profile, 'facebook', 'Facebook')
WHERE  market_profile LIKE '%facebook%';  