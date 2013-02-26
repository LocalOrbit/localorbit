<?php
class core_model_lo_order_status_changes extends core_model_base_lo_order_status_changes
{
	function init_fields()
	{
		global $core;

		$this->autojoin(
			'left',
			'lo_delivery_statuses',
			'(lo_delivery_statuses.ldstat_id = lo_order_status_changes.ldstat_id)',
			array('delivery_status')
		);
		$this->autojoin(
			'left',
			'lo_buyer_payment_statuses',
			'(lo_buyer_payment_statuses.lbps_id=lo_order_status_changes.lbps_id)',
			array('buyer_payment_status')
		);
		$this->autojoin(
			'left',
			'customer_entity',
			'(customer_entity.entity_id=lo_order_status_changes.user_id)',
			array('email')
		);
		parent::init_fields();
	}
}
?>