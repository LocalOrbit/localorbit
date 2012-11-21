<?
global $data;

$orgs = core::model('organizations')
	->collection()
	->filter('organizations.org_id','in','(select otd2.org_id from organizations_to_domains otd2 where otd2.domain_id='.$data['domain_id'].' and otd2.orgtype_id=2)');
	
	
$last_paid = core_format::date($data['service_fee_last_paid']);
if($last_paid == '')
	$last_paid = 'Never';
	
$payment_methods = core::model('organization_payment_methods')
	->collection()
	->filter('org_id','in','(
		select org_id 
		from organizations_to_domains
		where domain_id='.$data['domain_id'].'
		and   orgtype_id=2
	)');
?>
<table class="form">
	<? if(lo3::is_admin()){ ?>
	<?=core_form::header_nv('Service Fee')?>
	<?=core_form::input_text('Service Fee','service_fee',core_format::price($data['service_fee']))?>
	<?=core_form::input_select(
		'Fee Schedule',
		'sfs_id',
		$data['sfs_id'],
		core::model('service_fee_schedules')->collection(),
		array(
			'text_column'=>'name',
			'value_column'=>'sfs_id',
			'select_style'=>'width:300px;',
	))?>
	<?=core_form::input_select(
		'Pay Fee Via',
		'opm_id',
		$data['opm_id'],
		$payment_methods,
		array(
			'text_column'=>'nbr1_last_4',
			'value_column'=>'opm_id',
			'select_style'=>'width:300px;',
			'option_prefix'=>'************',
	))?>	
	<?=core_form::value('Last Paid',$last_paid)?>
	<?=core_form::spacer_nv()?>
	
	<?=core_form::header_nv('Operational Fees')?>
	<?=core_form::input_select(
		'Payable Organization',
		'payable_org_id',
		$data['payable_org_id'],
		$orgs,
		array(
			'text_column'=>'name',
			'value_column'=>'org_id',
			'select_style'=>'width:300px;',
			'info'=>'This is the organization for whom payables are created when orders are placed',
		))?>
		
	<tr>
		<td class="label">Create Payables:</td>
		<td class="value">
			<select name="payables_create_on" style="width: 300px;">
				<option value="buyer_paid"<?=(($data['payables_create_on'] == 'buyer_paid')?' selected="selected"':'')?>>Buyer Pays</option>
				<option value="delivery"<?=(($data['payables_create_on'] == 'delivery')?' selected="selected"':'')?>>Products Delivered</option>
				<option value="buyer_paid_and_delivered"<?=(($data['payables_create_on'] == 'buyer_paid_and_delivered')?' selected="selected"':'')?>>Buyer Pays and Products Delivered</option>
				
			</select>
		</td>
	</tr>
	<?=core_form::input_text('Order minimum','order_minimum',floatval($data['order_minimum']))?>
	
	<?=core_form::input_text('LO Fee %','fee_percen_lo',floatval($data['fee_percen_lo']))?>
	<?=core_form::input_text('Hub Fee %','fee_percen_hub',floatval($data['fee_percen_hub']))?>
	<?=core_form::input_text('Paypal Processing Fee %','paypal_processing_fee',floatval($data['paypal_processing_fee']))?>
	<?=core_form::input_check('Hub Covers Fees','hub_covers_fees',$data['hub_covers_fees'])?>
	<?=core_form::spacer_nv()?>
	<?=core_form::header_nv('Allowed Payment Methods',array(
		'info'=>$core->i18n['note:allowed_payment_methods'],
		'info_icon'=>'speech',
		'info_show'=>true
	))?>
	
	<?=core_form::input_check('Allow CC via Paypal','payment_allow_paypal',$data['payment_allow_paypal'],array(
		'onclick'=>'market.allowPaymentChanged(\'paypal\');',
	))?>
	<?=core_form::input_check('Allow Purchase Orders','payment_allow_purchaseorder',$data['payment_allow_purchaseorder'],array(
		'onclick'=>'market.allowPaymentChanged(\'purchaseorder\');market.togglePoDue();',
	))?>
	<tr id="allow_po_row"<?=(($data['payment_allow_purchaseorder']==0)?' style="display:none;"':'')?>>
		<td class="label">PO payments due</td>
		<td class="value"><input type="text" name="po_due_within_days" style="width:40px;" value="<?=intval($data['po_due_within_days'])?>" /> days</td>
	</tr>
	<?}?>
	
	<?=core_form::spacer_nv()?>
	<?=core_form::header_nv('Default Payment Methods',array(
		'info'=>$core->i18n['note:default_payment_methods'],
		'info_icon'=>'speech',
		'info_show'=>true
	))?>
	<tr id="div_payment_allow_paypal"<?=(($data['payment_allow_paypal'] == 1)?'':' style="display:none;"')?>>
		<td class="label">&nbsp;</td>
		<td class="value"><?=core_ui::checkdiv('payment_default_paypal','CC via Paypal',$data['payment_default_paypal'],'market.defaultPaymentChanged(\'paypal\');')?></td>
	</tr>
	<tr id="div_payment_allow_purchaseorder"<?=(($data['payment_allow_purchaseorder'] == 1)?'':' style="display:none;"')?>>
		<td class="label">&nbsp;</td>
		<td class="value"><?=core_ui::checkdiv('payment_default_purchaseorder','Purchase Orders',$data['payment_default_purchaseorder'],'market.defaultPaymentChanged(\'purchaseorder\');')?></td>
	</tr>
	<?if(lo3::is_admin()){?>
	<tr>
		<td colspan="2"><br/ ><h3>Seller Payments</h3></td>
	</tr>
	<tr>
		<td class="label">&nbsp;</td>
		<td class="value">
			<?=core_ui::radiodiv('seller_payer_lo','LO pays seller',($data['seller_payer'] == 'lo'),'seller_payer')?>
			<br />
			<?=core_ui::radiodiv('seller_payer_hub','Hub pays seller',($data['seller_payer'] == 'hub'),'seller_payer')?>
		</td>
	</tr>
	<tr class="buyer_invoicer_options"<?=(($data['payment_allow_purchaseorder']==1)?'':' style="display:none;"')?>>
		<td colspan="2"><br/ ><h3>Buyer Invoicing</h3></td>
	</tr>
	<tr class="buyer_invoicer_options"<?=(($data['payment_allow_purchaseorder']==1)?'':' style="display:none;"')?>>
		<td class="label">&nbsp;</td>
		<td class="value">
			<?=core_ui::radiodiv('buyer_invoicer_lo','LO invoices buyer',($data['buyer_invoicer'] == 'lo'),'buyer_invoicer')?>
			<br />
			<?=core_ui::radiodiv('buyer_invoicer_hub','Hub invoices buyer',($data['buyer_invoicer'] == 'hub'),'buyer_invoicer')?>
		</td>
	</tr>
	<?}?>
</table>