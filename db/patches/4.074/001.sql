INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '001', '55650144');

update phrases set default_value='<h1>Invoice</h1><br><b>Reference: {invoicenbr}<br>Amount: {amount}<br>Due Date: {duedate}<br>&nbsp;<br><h2>Payables</h2>{payables}<br>View and pay your invoice:&nbsp;<a target="_blank" rel="nofollow">{pay_link}</a></b>' where phrase_id=177;