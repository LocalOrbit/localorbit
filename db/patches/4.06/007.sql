INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.07', '006', '47552823');

INSERT INTO phrases
(default_value, label)
VALUE ('<h1>Echeck Payment Received</h1><br><b>Reference: {invoicenbr}<br>Market Name: {hubname}<br>Amount: {amount}<br>Date Received: {date_received}<br>&nbsp;<br>',
'email:payments:payment_received_body_ach');

INSERT INTO phrases
(default_value, label)
VALUE ('Echeck Payment Received',
'email:payments:payment_received_subject_ach');



INSERT INTO phrases
(default_value, label)
VALUE ('<h1>You have been sent a payment</h1><br><b>Reference: {invoicenbr}<br>Market Name: {hubname}<br>Amount: {amount}<br>Date Received: {date_received}<br>&nbsp;<br>',
'email:payments:payment_received_body_other');

INSERT INTO phrases
(default_value, label)
VALUE ('You have been sent a payment',
'email:payments:payment_received_subject_other');



