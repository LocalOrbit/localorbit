<?php
class core_model_base_catalogindex_aggregation extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'aggregation_id','int',8,'','catalogindex_aggregation'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','catalogindex_aggregation'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','catalogindex_aggregation'));
		$this->add_field(new core_model_field(3,'key','string',-4,'','catalogindex_aggregation'));
		$this->add_field(new core_model_field(4,'data','string',8000,'','catalogindex_aggregation'));
		$this->init_data();
	}
}
?>