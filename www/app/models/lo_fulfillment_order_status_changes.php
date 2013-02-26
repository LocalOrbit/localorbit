<?php
class core_model_lo_fulfillment_order_status_changes extends core_model_base_lo_fulfillment_order_status_changes
{
	function init_fields()
	{
		global $core;

		$this->autojoin(
			'left',
			'lo_delivery_statuses',
			'(lo_delivery_statuses.ldstat_id = lo_fulfillment_order_status_changes.ldstat_id)',
			array('delivery_status')
		);
		$this->autojoin(
			'left',
			'lo_seller_payment_statuses',
			'(lo_seller_payment_statuses.lsps_id=lo_fulfillment_order_status_changes.lsps_id)',
			array('seller_payment_status')
		);
		$this->autojoin(
			'left',
			'customer_entity',
			'(customer_entity.entity_id=lo_fulfillment_order_status_changes.user_id)',
			array('email')
		);
		parent::init_fields();
	}
}
?>