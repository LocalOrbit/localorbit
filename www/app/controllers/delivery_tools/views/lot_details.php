<?php
// print_r($core->data);
$lots = core::model('lo_order_line_item')->get_lots(
	$core->data['prod_id'],
	split(' ', $core->data['lodeliv_id']),
	$core->data['org_id']
);
foreach ($lots as $lot) {
echo '<br/> Lot #' . $lot['lot_id'] . ': ' . intval($lot['sum_qty']);
}
?>
