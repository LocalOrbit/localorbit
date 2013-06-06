
drop table if exists payables;
drop table if exists payable_types;
drop table if exists payments;
drop table if exists invoices;
drop table if exists x_invoices_payments;

RENAME TABLE payables TO old_payables;
RENAME TABLE payable_types TO old_payable_types;
RENAME TABLE payments TO old_payments;
RENAME TABLE invoices TO old_invoices;
RENAME TABLE x_invoices_payments TO old_x_invoices_payments;