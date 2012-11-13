<?
global $data;

$orgs = core::model('organizations')
	->collection()
	->filter('organizations.org_id','in','(select otd2.org_id from organizations_to_domains otd2 where otd2.domain_id='.$data['domain_id'].' and otd2.orgtype_id=2)');
?>
<table class="form">
	<? if(lo3::is_admin()){?>
	<tr>
		<td colspan="2"><h3>Fees</h3></td>
	</tr>
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
	<tr>
		<td class="label">Order minimum</td>
		<td class="value"><input type="text" name="order_minimum" value="<?=floatval($data['order_minimum'])?>" /></td>
	</tr>
	<tr>
		<td class="label">LO Fee %</td>
		<td class="value"><input type="text" name="fee_percen_lo" value="<?=$data['fee_percen_lo']?>" /></td>
	</tr>
	<tr>
		<td class="label">Hub Fee %</td>
		<td class="value"><input type="text" name="fee_percen_hub" value="<?=$data['fee_percen_hub']?>" /></td>
	</tr>
	<tr>
		<td class="label">Paypal Processing Fee %</td>
		<td class="value"><input type="text" name="paypal_processing_fee" value="<?=$data['paypal_processing_fee']?>" /></td>
	</tr>
	<tr>
		<td class="label">&nbsp;</td>
		<td class="value"><?=core_ui::checkdiv('hub_covers_fees','Hub Covers Fees',$data['hub_covers_fees'])?></td>
	</tr>
	<tr>
		<td colspan="2"><br/ ><h3>Allowed Payment Methods<?=core_form::info($core->i18n['note:allowed_payment_methods'],'speech',true)?></h3></td>
	</tr>
	<tr>
		<td class="label">&nbsp;</td>
		<td class="value"><?=core_ui::checkdiv('payment_allow_paypal','Allow CC via Paypal',$data['payment_allow_paypal'],'market.allowPaymentChanged(\'paypal\');')?></td>
	</tr>
	<tr>
		<td class="label">&nbsp;</td>
		<td class="value"><?=core_ui::checkdiv('payment_allow_purchaseorder','Allow Purchase Orders',$data['payment_allow_purchaseorder'],'market.allowPaymentChanged(\'purchaseorder\');market.togglePoDue();')?></td>
	</tr>
	<tr id="allow_po_row"<?=(($data['payment_allow_purchaseorder']==0)?' style="display:none;"':'')?>>
		<td class="label">PO payments due</td>
		<td class="value"><input type="text" name="po_due_within_days" style="width:40px;" value="<?=intval($data['po_due_within_days'])?>" /> days</td>
	</tr>
	<?}?>
	<tr>
		<td colspan="2"><br/ ><h3>Default Payment Methods<?=core_form::info($core->i18n['note:default_payment_methods'],'speech',true)?></h3></td>
	</tr>
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