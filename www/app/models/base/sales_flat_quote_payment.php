<?php
class core_model_base_sales_flat_quote_payment extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payment_id','int',8,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(1,'quote_id','int',8,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(3,'updated_at','timestamp',4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(4,'method','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(5,'cc_type','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(6,'cc_number_enc','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(7,'cc_last4','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(8,'cc_cid_enc','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(9,'cc_owner','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(10,'cc_exp_month','int',8,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(11,'cc_exp_year','int',8,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(12,'cc_ss_owner','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(13,'cc_ss_start_month','int',8,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(14,'cc_ss_start_year','int',8,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(15,'cybersource_token','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(16,'paypal_correlation_id','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(17,'paypal_payer_id','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(18,'paypal_payer_status','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(19,'po_number','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(20,'parent_id','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(21,'additional_data','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(22,'cc_ss_issue','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(23,'amazonfps_payer_id','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(24,'amazonfps_payer_status','string',-4,'','sales_flat_quote_payment'));
		$this->add_field(new core_model_field(25,'amazonfps_correlation_id','string',-4,'','sales_flat_quote_payment'));
		$this->init_data();
	}
}
?>