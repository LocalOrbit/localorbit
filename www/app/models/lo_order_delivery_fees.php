<?php

class core_model_lo_order_delivery_fees extends core_model_base_lo_order_delivery_fees
{
	function init_fields() 
	{
		$this->autojoin(
			'left',
			'fee_calc_types',
			'(lo_order_delivery_fees.fee_calc_type_id = fee_calc_types.fee_calc_type_id)',
			array('fee_calc_description'));

		parent::init_fields();
	}

	function apply_to_order($order)
	{
		global $core;
		$fee = 0;
		return $fee;
	}
	
	function add_order_joins()
	{
		$this->autojoin(
			'inner',
			'lo_order',
			'(lo_order.lo_oid=lo_order_delivery_fees.lo_oid)',
			array(
				'lo_order.fee_percen_lo','lo_order.fee_percen_hub','lo_order.paypal_processing_fee',
				'amount_paid','lo3_order_nbr','payment_method','UNIX_TIMESTAMP(order_date) as order_date',
			)
		);
		$this->autojoin(
			'inner',
			'domains',
			'(lo_order.domain_id=domains.domain_id)',
			array(
				'domains.name as domain_name'
			)
		);
		$this->autojoin(
			'inner',
			'organizations',
			'(lo_order.org_id=organizations.org_id)',
			array(
				'organizations.org_id','organizations.name as buyer_org_name'
			)
		);
		$this->autojoin(
			'inner',
			'lo_delivery_statuses',
			'(lo_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
			array(
				'delivery_status'
			)
		);
		$this->autojoin(
			'inner',
			'lo_buyer_payment_statuses',
			'(lo_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',
			array(
				'buyer_payment_status'
			)
		);
		return $this;
	}
}

?>