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
	
	function insert_percent_fee($lo_oid)
	{
		core_db::query("INSERT INTO lo_order_delivery_fees
			(lo_oid, devfee_id, dd_id, fee_type, fee_calc_type_id, amount, applied_amount)
			SELECT lo_order_line_item.lo_oid,
			delivery_fees.devfee_id,
			delivery_fees.dd_id,
			'delivery' AS fee_type,
			1 AS fee_calc_type_id ,
			delivery_fees.amount AS amount,
			Round(SUM(COALESCE(delivery_fees.amount / 100 * row_total,0)),2) AS applied_amount
			FROM delivery_fees INNER JOIN lo_order_line_item ON delivery_fees.dd_id = lo_order_line_item.dd_id
			WHERE delivery_fees.fee_calc_type_id = 1 /* percentage amount */
			AND lo_order_line_item.lo_oid=".intval($lo_oid)
		);
	}
	
	function update_percent_fee($lo_oid)
	{
		core_db::query("
			update lo_order_delivery_fees
			set applied_amount = Round((lo_order_delivery_fees.amount / 100) * (
				select sum(lo_order_line_item.row_total)
				from lo_order_line_item
				where lo_order_line_item.lo_oid=".intval($lo_oid)."
			),2)
			
			WHERE lo_order_delivery_fees.fee_calc_type_id = 1 /* percentage amount */
			AND lo_order_delivery_fees.lo_oid=".intval($lo_oid)
		);
	}
	
	function insert_flat_fee($lo_oid)
	{
		// applied 1 time per delivery day
		core_db::query("INSERT INTO lo_order_delivery_fees
			(lo_oid, devfee_id, dd_id, fee_type, fee_calc_type_id, amount, applied_amount)
			SELECT DISTINCT lo_order_line_item.lo_oid,
			  delivery_fees.devfee_id,
			  delivery_fees.dd_id,
			  'delivery' AS fee_type,
			  2 AS fee_calc_type_id ,
			delivery_fees.amount AS   amount,
			delivery_fees.amount AS   applied_amount
			FROM delivery_fees INNER JOIN lo_order_line_item ON delivery_fees.dd_id = lo_order_line_item.dd_id
			WHERE delivery_fees.fee_calc_type_id = 2 /* flat amount */
			AND lo_order_line_item.lo_oid=".intval($lo_oid)
		);
	
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