INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.06', '008', '47552823');

UPDATE phrases SET default_value = 'We will email you a new password.' WHERE label = 'note:resetpassword';
UPDATE phrases SET default_value = 'Reset Password' WHERE label = 'button:resetpassword';