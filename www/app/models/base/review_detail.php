<?php
class core_model_base_review_detail extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'detail_id','int',8,'','review_detail'));
		$this->add_field(new core_model_field(1,'review_id','int',8,'','review_detail'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','review_detail'));
		$this->add_field(new core_model_field(3,'title','string',-4,'','review_detail'));
		$this->add_field(new core_model_field(4,'detail','string',8000,'','review_detail'));
		$this->add_field(new core_model_field(5,'nickname','string',-4,'','review_detail'));
		$this->add_field(new core_model_field(6,'customer_id','int',8,'','review_detail'));
		$this->init_data();
	}
}
?>