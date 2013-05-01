
drop table if exists payables;
drop table if exists payments;
drop table if exists invoices;
drop table if exists x_invoices_payments;


RENAME TABLE new_invoices TO invoices;
RENAME TABLE new_payments TO payments;



