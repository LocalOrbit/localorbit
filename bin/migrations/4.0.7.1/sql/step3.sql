RENAME TABLE payables TO old_payables;
RENAME TABLE payable_types TO old_payable_types;
RENAME TABLE payments TO old_payments;
RENAME TABLE invoices TO old_invoices;
RENAME TABLE x_invoices_payments TO old_x_invoices_payments;


RENAME TABLE new_invoices TO invoices;
RENAME TABLE new_payments TO payments;
RENAME TABLE new_payables TO payables;



