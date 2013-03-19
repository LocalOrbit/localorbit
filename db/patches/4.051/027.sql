
INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('027', '46498917');

CREATE index payments_idx1 on payments (to_org_id) using hash;
CREATE index payments_idx2 on payments (from_org_id) using hash;

drop index organizations_to_domains_idx1 on organizations_to_domains;
drop index organizations_to_domains_idx2 on organizations_to_domains;
drop index organizations_to_domains_idx3 on organizations_to_domains;
drop index organizations_to_domains_idx4 on organizations_to_domains;
CREATE index organizations_to_domains_idx1 on organizations_to_domains (domain_id) using hash;
CREATE index organizations_to_domains_idx2 on organizations_to_domains (org_id) using hash;
CREATE index organizations_to_domains_idx3 on organizations_to_domains (orgtype_id) using hash;
CREATE index organizations_to_domains_idx4 on organizations_to_domains (is_home) using hash;


CREATE index payables_idx1 on payables (domain_id) using hash;
CREATE index payables_idx2 on payables (payable_type_id) using hash;
CREATE index payables_idx3 on payables (from_org_id) using hash;
CREATE index payables_idx4 on payables (to_org_id) using hash;
CREATE index payables_idx5 on payables (invoice_id) using hash;


CREATE index invoices_idx1 on invoices (from_org_id) using hash;
CREATE index invoices_idx2 on invoices (to_org_id) using hash;

CREATE index x_invoices_payments_idx1 on x_invoices_payments (invoice_id) using hash;
CREATE index x_invoices_payments_idx2 on x_invoices_payments (payment_id) using hash;

