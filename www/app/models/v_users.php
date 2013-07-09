<?php
class core_model_v_users extends core_model_base_v_users
{
}

function v_users__enable_suspend_links($data)
{
	$data['activate_action'] = ($data['is_active'] == 1)?'deactivate':'activate';
	$data['enable_action'] = ($data['is_enabled'] == 1)?'suspend':'enable';
	$data['enable_icon'] = ($data['is_enabled'] == 1)?'minus':'plus';
	return $data;
}

?>