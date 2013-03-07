INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('019', '43173555');

UPDATE `phrases`
SET
`default_value` = '<h1>Hooray!</h1>A new organization has registered for your market! Their contact info is below:<br>&nbsp;<br>Company: {company}<br>Name: {fullname}<br>Email: {email}<br><br>To activate this organization, <a href="{dashboard}">click here. </a> <br>Thank you!<br>'
WHERE phrase_id = 96;
