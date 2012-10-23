INSERT INTO phrases
(
`pcat_id`,
`label`,
`tags`,
`default_value`,
`sort_order`,
`edit_type`,
`info_note`)
VALUES
(
'8', 
'email:new_registrant_auto_activate',
 NULL, 
'<h1>Please click the link below!</h1>Thank you for registering with {hubname}. To shop or sell online, you must verify your email address by clicking this link: <br>&nbsp;<a href=\"{link}\">{link}</a><br>&nbsp;<br>If clicking the link doesn\'t work, copy and paste it into a new browser window.<br>Thank you for supporting {hubname} and your local food producers!<br>', 
'1', 
'rte', 
'You have the following fields available: {first_name}, {link}, {hostname}'
);
