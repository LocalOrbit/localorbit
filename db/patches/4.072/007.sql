
INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.072', '007', '54235380');

UPDATE phrases
SET default_value = '<h1>almost there!</h1>Dear {first_name},<br>&nbsp;<br>Thank you for registering with {hubname}, your online ordering service for local food. <br>&nbsp;<br>To activate your account, please click on the following link:<br><a rel="nofollow" target="_blank" href="{link}">{link}</a>.<br>&nbsp;<br> If clicking on the link does not work, copy and paste URL above into a new browser window.'
WHERE label = 'email:new_registrant_auto_activate';

UPDATE phrases
SET default_value = '<h1>Please click the link below!</h1>Thank you for registering with {hubname}. To shop or sell online, you must verify your email address by clicking this link: <br>&nbsp;<a rel="nofollow" target="_blank" href="{link}">{link}</a><br>&nbsp;<br>Once the {hubname} Market Manager activates your account, you\'ll be all set!<br><br>If clicking the link doesn\'t work, copy and paste it into a new browser window.<br>Thank you for supporting {hubname} and your local food producers!<br>'
WHERE label = 'email:new_registrant';