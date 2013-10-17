<?php 



$order_sql = "SELECT DISTINCT
			
			UNIX_TIMESTAMP(lo_order.order_date) AS order_date_u,
			lo_order.order_date		
		FROM lo_order
		WHERE lo_order.lo_oid = 17188";

	$orderInfos = new core_collection($order_sql);
	foreach($orderInfos as $orderInfo) {
		$orderInfo = $orderInfo;
	}

	echo $orderInfo['order_date'];
	echo "'order_date' <br>";

	echo core_format::date($orderInfo['order_date'],'short');
	echo "'order_date'],'short<br>";

	echo core_format::date($orderInfo['order_date'],'long');
	echo "order_date'],'long<br>";
	echo $core->session['time_offset'];

	
	
	

	$due_date_unixtime = $orderInfo['order_date_u'] + 60 * 60 * 24 * 14;
	
	echo "Payment Due: <b>".core_format::date($due_date_unixtime,'long')."</b><br />";
?>