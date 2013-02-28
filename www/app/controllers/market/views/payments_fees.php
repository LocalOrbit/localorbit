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
				'default_show'=>true,
				'default_text'=>'Select an account',
				'default_value'=>0,
				'text_column'=>'nbr1_last_4',
				'value_column'=>'opm_id',
				'select_style'=>'width:300px;',
				'option_prefix'=>'************',
		))?>	
		<?=core_form::value('Last Paid',$last_paid)?>

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

		<div class="control-group">
			<label class="control-label">Create Payables</label>
			<div class="controls">
				<select name="payables_create_on">
					<option value="buyer_paid"<?=(($data['payables_create_on'] == 'buyer_paid')?' selected="selected"':'')?>>Buyer Pays</option>
					<option value="delivery"<?=(($data['payables_create_on'] == 'delivery')?' selected="selected"':'')?>>Products Delivered</option>
					<option value="buyer_paid_and_delivered"<?=(($data['payables_create_on'] == 'buyer_paid_and_delivered')?' selected="selected"':'')?>>Buyer Pays and Products Delivered</option>
				</select>
			</div>
		</div>

		<?=core_form::input_text('Order minimum','order_minimum',floatval($data['order_minimum']))?>
	
		<?=core_form::input_text('LO Fee %','fee_percen_lo',floatval($data['fee_percen_lo']))?>
		<?=core_form::input_text('Hub Fee %','fee_percen_hub',floatval($data['fee_percen_hub']))?>
		<?=core_form::input_text('Paypal Processing Fee %','paypal_processing_fee',floatval($data['paypal_processing_fee']))?>
		<?=core_form::input_check('Hub Covers Fees','hub_covers_fees',$data['hub_covers_fees'])?>

		<?=core_form::header_nv('Allowed Payment Methods',array(
			'info'=>$core->i18n['note:allowed_payment_methods'],
			'info_icon'=>'speech',
			'info_show'=>true
		))?>
	
		<?=core_form::input_check('Allow CC via Paypal','payment_allow_paypal',$data['payment_allow_paypal'],array(
			'onclick'=>'market.allowPaymentChanged(\'paypal\');',
		))?>
		<?=core_form::input_check('Allow ACH','payment_allow_ach',$data['payment_allow_ach'],array(
			'onclick'=>'market.allowPaymentChanged(\'ach\');',
		))?>	
		<?=core_form::input_check('Allow Purchase Orders','payment_allow_purchaseorder',$data['payment_allow_purchaseorder'],array(
			'onclick'=>'market.allowPaymentChanged(\'purchaseorder\');market.togglePoDue();',
		))?>
		

		<div class="control-group" id="po_due_option"<?=(($data['payment_allow_purchaseorder']==0)?' style="display:none;"':'')?>>
			<label class="control-label">PO payments due</label>
			<div class="controls">
				<input type="text" name="po_due_within_days" class="input-xxsmall" value="<?=intval($data['po_due_within_days'])?>" /> days
			</div>
		</div>
	
	<?}?>
	
	<?=core_form::header_nv('Default Payment Methods',array(
		'info'=>$core->i18n['note:default_payment_methods'],
		'info_icon'=>'speech',
		'info_show'=>true
	))?>
	
	<?= core_form::input_check('CC via Paypal','payment_default_paypal', $data['payment_default_paypal'], array('display_row'=>($data['payment_allow_paypal'] == 1),'checked' => 'market.defaultPaymentChanged(\'paypal\');','row_id'=>'div_payment_allow_paypal')); ?>
	<?= core_form::input_check('ACH','payment_default_ach', $data['payment_default_ach'], array('display_row'=>($data['payment_allow_ach'] == 1),'checked' => 'market.defaultPaymentChanged(\'ach\');','row_id'=>'div_payment_allow_ach')); ?>	
	<?= core_form::input_check('Purchase Orders','payment_default_purchaseorder', $data['payment_default_purchaseorder'], array('display_row'=>($data['payment_allow_purchaseorder'] == 1),'checked' => 'market.defaultPaymentChanged(\'purchaseorder\');','row_id'=>'div_payment_allow_purchase_order')); ?>

	<?if(lo3::is_admin()){?>
	<h3>Seller Payments</h3>
	
	<div class="control-group">
		<label class="control-label">Who pays the seller?</label>
		<div class="controls">
			<?=core_ui::radiodiv('seller_payer_lo','Local Orbit pays seller',($data['seller_payer'] == 'lo'),'seller_payer')?>
			<?=core_ui::radiodiv('seller_payer_hub','Market pays seller',($data['seller_payer'] == 'hub'),'seller_payer')?>
		</div>
	</div>

	<? if($data['payment_allow_purchaseorder']==1): ?>
		<h3>Buyer Invoicing</h3>
		
		<div class="control-group">
			<label class="control-label">Who invoices the buyer?</label>
			<div class="controls">
				<?=core_ui::radiodiv('buyer_invoicer_lo','Local Orbit invoices buyer',($data['buyer_invoicer'] == 'lo'),'buyer_invoicer')?>
				<?=core_ui::radiodiv('buyer_invoicer_hub','Market invoices buyer',($data['buyer_invoicer'] == 'hub'),'buyer_invoicer')?>
			</div>
		</div>
	<? endif;?>

	<?}?>