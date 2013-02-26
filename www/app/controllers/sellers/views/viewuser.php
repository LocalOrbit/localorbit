<?php 
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

$user = core::model('customer_entity')->load($core->data['user_id']);
$user->dump();
?>
