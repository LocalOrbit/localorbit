<?php

class core_controller_options extends core_controller
{
	function get_products()
	{		
		global $core;
		$domain_id = (is_numeric($core->data['filterParam'])) ? $core->data['filterParam'] :$core->config['domain']['domain_id'];
		$products = core::model('products')->get_catalog($domain_id)->sort('p.name')->sort('o.name');					
		$data = array();
		foreach($products as $product)
		{
			$data[$product['prod_id']] = $product['org_name'].': '.$product['name'];
		}
		$this->writeback($data);
	}
	
	function writeback($data)
	{
		global $core;
		core::js('core.lo3.insertUpdatedDataForSelector('.json_encode($data).',\''.$core->data['formName'].'\',\''.$core->data['selectorName'].'\',\''.$core->data['defaultText'].'\');');
		core::deinit();
	}
}

?>