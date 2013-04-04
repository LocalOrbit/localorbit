INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('030', '47456035');


update phrases set default_value='<h1>Invoice</h1><br><b>Reference: {invoicenbr}<br>Amount: {amount}<br>Due Date: {duedate}<br>&nbsp;<br><h2>Payables</h2>{payables}<br>View your invoice:&nbsp;<a target="_blank" rel="nofollow" title="Link: null">{pay_link}</a></b> '
where label='email:payments:new_invoice_body';