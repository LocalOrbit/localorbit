<?php
class core_model_base_organization_delivery_cross_sells extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ocs_id','int',8,'','organization_delivery_cross_sells'));
		$this->add_field(new core_model_field(1,'org_id','int',8,'','organization_delivery_cross_sells'));
		$this->add_field(new core_model_field(2,'dd_id','int',8,'','organization_delivery_cross_sells'));
		$this->init_data();
	}
}
?>