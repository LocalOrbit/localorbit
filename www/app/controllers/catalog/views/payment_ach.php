<?
global $core;
global $org;
if($org['payment_allow_ach'] == 1)
{
	$methods = core::model('organization_payment_methods')
		->collection()
		->filter('org_id','=',$org['org_id'])
		->add_formatter('organization_payment_methods__formatter_dropdown');
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
?>
<div id="payment_ach" class="payment_option span6 form"<?=$style?>>
	<h4>ACH Information</h4>
	<br />
	<?=core_form::input_select('Account','opm_id','',$methods,array(
		'text_column'=>'dropdown_text',
		'value_column'=>'opm_id',
		'select_style'=>'width:320px;',
	))?>
</div>
<?}?>