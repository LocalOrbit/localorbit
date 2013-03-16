INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('026', '38206223');



UPDATE phrases
SET default_value = 'We will email you a link to reset your password.'
WHERE label = 'button:resetpassword';

UPDATE phrases
SET default_value = 'sign me up'
WHERE label = 'button:signup';


  
UPDATE phrases
SET default_value = '<h1>almost there!</h1>Dear {first_name},<br />&nbsp;<br />Thank you for registering with {hubname}, your online ordering service for local food. <br />&nbsp;<br />To activate your account, please click on the following link:<br /><a href="{link}">{link}</a>.<br />&nbsp;<br /> If clicking on the link does not work, copy and paste URL above into a new browser window.'
WHERE label = 'email:new_registrant_auto_activate';
  
  


