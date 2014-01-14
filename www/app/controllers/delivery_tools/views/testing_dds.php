<?php


$dd = core::model('delivery_days')->load($core->data['dd_id']);
$result = $dd->next_time();


echo('start time should be: '.$dd['delivery_time'].'<br />');
echo('UTC formatted delivery start time is: '.(date('Y-m-d H:i:s',$dd['delivery_start_time'])).'<br />');
echo('UTC formatted due time is: '.(date('Y-m-d H:i:s',$dd['due_time'])).'<br />');
echo('system formatted due time is (admin timezone): '.(core_format::date($dd['due_time'],'long')).'<br />');
echo('cutoff time is (admin timezone): '.(core_format::date($dd['due_time'],'long')).'<br />');


echo('Raw Data:<pre>');
print_r($dd->__data);
echo('</pre>');
#core::js('window.clearInterval(core.myInterval);core.myInterval=window.setInterval(function(){core.doRequest(\'/delivery_tools/testing_dds\',{});},1000);');
?>
