INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('024', '45895601');


UPDATE weekly_specials
SET body = 'Here\'s the feature:'
WHERE spec_id = 8;



UPDATE phrases
SET default_value = 'We will email you a link to reset your password.'
WHERE phrase_id = 8;

