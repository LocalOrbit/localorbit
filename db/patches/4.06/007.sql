INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.06', '007', '47552823');

DELETE FROM phrases WHERE label = 'email:payments:payment_received_body_ach';
DELETE FROM phrases WHERE label = 'email:payments:payment_received_subject_ach';

DELETE FROM phrases WHERE label = 'email:payments:payment_received_body_other';
DELETE FROM phrases WHERE label = 'email:payments:payment_received_subject_other';



INSERT INTO phrases
(default_value, label)
VALUE ('<h1>You have made a payment</h1><br>Paid To: {paid_to}<br>Received  From: {received_from}<br>Amount: {amount}<br>Date Received: {date_received}<br>&nbsp;<br>',
'email:payments:payment_made_body');

INSERT INTO phrases
(default_value, label)
VALUE ('You have made a payment',
'email:payments:payment_made_subject');


INSERT INTO phrases
(default_value, label)
VALUE ('<h1>You have been sent a payment</h1><br>Paid To: {paid_to}<br>Received  From: {received_from}<br>Amount: {amount}<br>Date Received: {date_received}<br>&nbsp;<br>',
'email:payments:payment_received_body');

INSERT INTO phrases
(default_value, label)
VALUE ('You have been sent a payment',
'email:payments:payment_received_subject');


