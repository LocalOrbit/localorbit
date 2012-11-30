<?
global $core;

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

function is_invoice($order)
{
	return $order['ldstat_id'] != 1 and $order['ldstat_id'] != 3 and $order['ldstat_id'] != 6 and
	 ($order['lbps_id'] == 2 or $order['lbps_id'] == 4 or $order['lbps_id'] == 3 or $order['lbps_id'] == 1)
	and $order['adjusted_total'] > 0;
}

function is_payable($order)
{
	return $order['ldstat_id'] != 1 and $order['ldstat_id'] != 3 and $order['ldstat_id'] != 6
	and $order['lbps_id'] != 5 and $order['lbps_id'] != 6
	and $order['adjusted_total'] > 0;
}

function is_payment($order)
{
	return $order['ldstat_id'] != 1 and $order['ldstat_id'] != 3 and $order['ldstat_id'] != 6 and
	 ($order['lbps_id'] == 2 or $order['lbps_id'] == 4)
	and $order['adjusted_total'] > 0;
}

$orders =
	core::model('lo_order')
	->autojoin('inner','payment_methods','lo_order.payment_method = payment_methods.payment_method')
	->collection()
	->filter('domains.domain_id','is not null');

while ($order = $orders->row())
{
	echo "Order #" . $order['lo_oid'] . '...';
	$to_org_id = ($order['seller_payment_managed_by'] != 'fully_managed' && $order['payment_method'] == 'purchaseorder') ? $order['payable_org_id'] : 1;

	if (is_payable($order))
	{
		if (is_invoice($order))
		{
			$invoice = core::model('invoices');
			$invoice['from_org_id'] = $order['org_id'];
			$invoice['to_org_id'] = $to_org_id;
			$invoice['amount'] = $order['adjusted_total'];
			$invoice['is_imported'] = 1;
			$invoice['due_date']  = $order['order_date'] + $order['po_due_within_days']*24*60*60;
			$invoice->save();
			echo 'invoice...';

			if (is_payment($order))
			{
				$payment = core::model('payments');
				$payment['from_org_id'] = $order['org_id'];
				$payment['to_org_id']= $to_org_id;
				$payment['amount'] = $order['amount_paid'];
				$payment['payment_method_id'] = $order['payment_method_id'];
				$payment['ref_nbr'] = $order['payment_ref'];
				$payment['admin_note'] = $order['admin_note'];
				$payment['is_imported'] = 1;
				$payment['creation_date']  = max($order['order_date'] + $order['po_due_within_days']*24*60*60, $order['last_status_date']);
				$payment->save();

				$payment_invoice = core::model('x_invoices_payments');
				$payment_invoice['invoice_id'] = $invoice['invoice_id'];
				$payment_invoice['payment_id']= $payment['payment_id'];
				$payment_invoice['amount_paid'] = $order['amount_paid'];
				$payment_invoice->save();
				echo 'payment...';
			}
		}

		$payable = core::model('payables');
		$payable['domain_id'] = $order['domain_id'];
		$payable['payable_type_id'] = 1;
		$payable['parent_obj_id'] = $order['lo_order'];
		$payable['from_org_id'] = $order['org_id'];
		$payable['to_org_id'] = $to_org_id;
		$payable['amount'] = $order['adjusted_total'];
		$payable['invoice_id'] = isset($invoice) ? $invoice['invoice_id'] : $invoice;
		$payable['invoicable'] = 1;
		$payable['is_imported'] = 1;
		$payable['creation_date'] = $order['order_date'];
		$payable->save();
		echo 'payable...';
	}

	echo "done.\n";
}

?>