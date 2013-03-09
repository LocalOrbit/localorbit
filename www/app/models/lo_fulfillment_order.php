<?php
class core_model_lo_fulfillment_order extends core_model_base_lo_fulfillment_order
{
	function init_fields()
	{
		$this->autojoin(
			'left',
			'domains',
			'(lo_fulfillment_order.domain_id=domains.domain_id)',
			array('payables_create_on', 'domains.name as domain_name', 'domains.paypal_processing_fee as domain_paypal_processing_fee', 'seller_payment_managed_by')
		);
		parent::init_fields();
		return $this;
	}
	function load_items()
	{
		global $core;
		$this->items = core::model('lo_order_line_item')
			->collection()
			->filter('lo_foid',$this['lo_foid'])
			->sort('deliv_time')
			->sort('seller_name');
		#$this->items->load();
		return $this->items;
	}

	function send_emails($order)
	{
		global $core;
		core::log('sending email to seller org '.$this['org_id']);
		$users = core::model('customer_entity')->collection()->filter('org_id',$this['org_id']);
		$domain = core::model('domains')->load($this['domain_id']);

		$user_list = array();
		foreach($users as $useritem)
		{
			$user_list[] = $useritem['email'];
		}


		core::process_command('emails/order_seller',false,
			$user_list,
			$fullname,
			$this['lo3_order_nbr'],
			$order->items,
			$this['payment_method'],
			$this['payment_ref'],
			$domain['domain_id'],
			$domain['hostname'],
			$domain['name'],
			$this['org_id']
		);

	}

	function create_order_payables ($payment_method,$parent)
	{
		global $core;

		core::log('trying to calculate fulfillment payable. totals are : '.$this['grand_total'].' / '.$this['adjusted_total']);
		$total = floatval(($this['adjusted_total']));
		$fees  = floatval($parent['fee_percen_lo'] + $parent['fee_percen_hub'] + floatval($parent[$payment_method.'_processing_fee']));
		$fees  = ($fees / 100) * $total;
		$amount = $total - $fees;
		core::log('fees are: '.$fees);
		core::log('amount should be: '.($amount));
		
		# if the hub is in charge of paying sellers and lo has already received the money,
		# then lo owes the hub the money for the products, and the hub owes the money to the sellers
		#
		# if lo is in charge of pyaing the sellers, then lo owes the money to the sellers and that's it.
		if($core->config['domain']['seller_payer'] == 'hub')
		{
			if($payment_method == 'purchaseorder')
			{
				# create only one payable: hub to seller
				$payable = core::model('payables');
				$payable['domain_id'] = $core->config['domain']['domain_id'];
				$payable['amount'] = $amount;
				$payable['payable_type_id'] = 2;
				$payable['parent_obj_id'] = $this['lo_foid'];
				$payable['from_org_id'] = $core->config['domain']['payable_org_id'];
				$payable['to_org_id'] = $this['org_id'];
				$payable['description'] = $this['lo3_order_nbr'];
				$payable->save();
			}
			else
			{
				#  create first payable: lo to hub for seller products
				$payable = core::model('payables');
				$payable['domain_id'] = $core->config['domain']['domain_id'];
				$payable['amount'] = $amount;
				$payable['payable_type_id'] = 2;
				$payable['parent_obj_id'] = $this['lo_foid'];
				$payable['from_org_id'] = 1;
				$payable['to_org_id'] = $core->config['domain']['payable_org_id'];;
				$payable['description'] = $this['lo3_order_nbr'];
				$payable->save();
				
				# create second payable:  hub to seller for seller products
				$payable = core::model('payables');
				$payable['domain_id'] = $core->config['domain']['domain_id'];
				$payable['amount'] = $amount;
				$payable['payable_type_id'] = 2;
				$payable['parent_obj_id'] = $this['lo_foid'];
				$payable['from_org_id'] = $core->config['domain']['payable_org_id'];
				$payable['to_org_id'] = $this['org_id'];
				$payable['description'] = $this['lo3_order_nbr'];
				$payable->save();
			}
		
		}
		else
		{
			$payable = core::model('payables');
			$payable['domain_id'] = $core->config['domain']['domain_id'];
			$payable['amount'] = $amount;
			$payable['payable_type_id'] = 2;
			$payable['parent_obj_id'] = $this['lo_foid'];
			$payable['from_org_id'] = 1;
			$payable['to_org_id'] = $this['org_id'];
			$payable['description'] = $this['lo3_order_nbr'];
			$payable->save();
		}

	

		return $payable;
	}

	function get_status_history()
	{
		global $core;
		$this->history = core::model('lo_fulfillment_order_status_changes')
			->collection()
			->filter('lo_foid',$this['lo_foid'])
			->sort('creation_date')
			->to_array();
		return $this->history;
	}

	function get_item_status_history()
	{
		global $core;
		$this->item_history = new core_collection('
			SELECT
			loi_scid,lo_liid,lo_order_item_status_changes.ldstat_id,
			lo_order_item_status_changes.lbps_id,lo_order_item_status_changes.lsps_id,
			UNIX_TIMESTAMP(creation_date) as creation_date,
			lo_buyer_payment_statuses.buyer_payment_status,
			lo_seller_payment_statuses.seller_payment_status,
			lo_delivery_statuses.delivery_status
			FROM lo_order_item_status_changes
			left join lo_buyer_payment_statuses on lo_order_item_status_changes.lbps_id = lo_buyer_payment_statuses.lbps_id
			left join lo_seller_payment_statuses on lo_order_item_status_changes.lsps_id = lo_seller_payment_statuses.lsps_id
			left join lo_delivery_statuses on lo_order_item_status_changes.ldstat_id = lo_delivery_statuses.ldstat_id
			where lo_liid in (
				select lo_liid
				from lo_order_line_item
				where lo_foid = '.$this['lo_foid'].'
			)
			order by loi_scid;
		');
		$this->item_history = $this->item_history->to_hash('lo_liid');
		return $this->item_history;
	}

	function get_items_by_delivery()
	{
		global $core;
		$this->items = core::model('lo_order_line_item')
			->autojoin(
				'inner',
				'lo_delivery_statuses',
				'(lo_order_line_item.ldstat_id=lo_delivery_statuses.ldstat_id)',
				array('delivery_status')
			)->autojoin(
				'inner',
				'lo_seller_payment_statuses',
				'(lo_order_line_item.lsps_id=lo_seller_payment_statuses.lsps_id)',
				array('seller_payment_status')
			)->autojoin(
				'inner',
				'lo_buyer_payment_statuses',
				'(lo_order_line_item.lbps_id=lo_buyer_payment_statuses.lbps_id)',
				array('buyer_payment_status')
			)->autojoin(
				'left',
				'lo_order',
				'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
				array('lo_order.fee_percen_lo','lo_order.fee_percen_hub','lo_order.org_id as buyer_org_id')
			)
			->autojoin(
				'left',
				'lo_order_deliveries',
				'(lo_order_deliveries.lodeliv_id = lo_order_line_item.lodeliv_id)',
				array('delivery_start_time','delivery_end_time','pickup_start_time','pickup_end_time','lo_order_deliveries.dd_id')
			)
		->autojoin(
				'left',
				'addresses a1',
				'(a1.address_id = lo_order_deliveries.deliv_address_id)',
				array('a1.org_id as deliv_org_id','a1.address as delivery_address','a1.city as delivery_city','a1.postal_code as delivery_postal_code','a1.org_id as delivery_org_id')
			)
			->autojoin(
				'left',
				'addresses a2',
				'(a2.address_id = lo_order_deliveries.pickup_address_id)',
				array('a2.org_id as pickup_org_id','a2.address as pickup_address','a2.city as pickup_city','a2.postal_code as pickup_postal_code','a2.org_id as pickup_org_id')
			)
			->autojoin(
				'left',
				'directory_country_region dcr1',
				'(a1.region_id = dcr1.region_id)',
				array('dcr1.code as delivery_state')
			)
			->autojoin(
				'left',
				'directory_country_region dcr2',
				'(a2.region_id = dcr2.region_id)',
				array('dcr2.code as pickup_state')
			)
			->collection()
			->add_formatter('determine_delivery_language')
			->sort('delivery_start_time')
			->filter('lo_order_line_item.lo_foid',$this['lo_foid']);
		return $this->items;
	}

	function set_payable_invoicable ($invoicable)
	{
		$payable = core::model('payables')->collection()->filter('payable_type_id',2)->filter('parent_obj_id',$this['lo_foid'])->row();
		if ($payable && $payable['invoicable'] != $invoicable)
		{
			$payable['invoicable'] = $invoicable;
			$payable->save();
			core::log('changed payable for lo_fulfillment_order'. $this['lo_foid'] . ' invoicable to '.  $invoicable);
		}
	}

	function change_status($ldstat_id,$lsps_id,$lbps_id,$do_update=true)
	{
		global $core;

		if(!is_numeric($this['lo_foid']))
		{
			throw new Exception('Cannot change status of unsaved order');
		}

		if($this['ldstat_id'] != $ldstat_id)
		{
			$this['ldstat_id'] = $ldstat_id;
			$this['last_status_date'] = date('Y-m-d H:i:s');


			if ($ldstat_id == 4 && (($this['payables_create_on'] == 'delivery') ||
				($lbps_id == 2 && $this['payables_create_on'] =='buyer_paid_and_delivered')))
			{
				$this->set_payable_invoicable(true);
			}

			$stat_change = core::model('lo_fulfillment_order_status_changes');
			$stat_change['user_id'] = $core->session['user_id'];
			$stat_change['lo_foid'] = $this['lo_foid'];
			$stat_change['ldstat_id'] = $ldstat_id;
			$stat_change->save();
		}

		if($this['lsps_id'] != $lsps_id)
		{
			$this['lsps_id'] = $lsps_id;
			$this['last_status_date'] = date('Y-m-d H:i:s');

			$stat_change = core::model('lo_fulfillment_order_status_changes');
			$stat_change['user_id'] = $core->session['user_id'];
			$stat_change['lo_foid'] = $this['lo_foid'];
			$stat_change['lsps_id'] = $lsps_id;
			$stat_change->save();
		}

		if ($lbps_id == 2 && $this['payables_create_on'] == 'buyer_paid')
		{
			$this->set_payable_invoicable(true);
		}

		if($do_update)
		{
			$this->save();
		}
	}

}

function delivery_actions($data)
{
	if($data['status'] == 'ORDERED')
	{
		$data['actions'] = '<br /><a href="Javascript:core.doRequest(\'/orders/mark_order_delivered\',{\'lo_foid\':'.$data['lo_foid'].',\'src\':\'table\'});">Mark Delivered</a>';
	}
	else
	{
		$data['actions'] = '';
	}
	return $data;
}
?>