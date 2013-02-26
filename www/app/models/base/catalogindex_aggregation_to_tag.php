<?php
class core_model_base_catalogindex_aggregation_to_tag extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'aggregation_id','int',8,'','catalogindex_aggregation_to_tag'));
		$this->add_field(new core_model_field(1,'tag_id','int',8,'','catalogindex_aggregation_to_tag'));
		$this->init_data();
	}
}
?>