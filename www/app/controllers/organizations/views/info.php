<?
global $data,$domains,$all_domains;
$social_options = core::model('social_options')->collection()->to_array();
$domain = core::model('domains')->load($data['domain_id']);
$users = core::model('customer_entity')->add_custom_field('CONCAT(first_name, \' \', last_name) as full_name')->collection()->filter('is_deleted',0)->filter('is_enabled', 1)->filter('is_active', 1)->filter('org_id', $data['org_id']);
$style = ($data['orgtype_id']==2)?' style="display: none;"':'';
//print_r($users);
/*
$items = array();
$items[] = core_form::input_text('Name:','name',$data,true);
$items[] = core_form::input_text($core->i18n['organizations:facebook'].':','facebook',$data);
$items[] = core_form::input_text($core->i18n['organizations:twitter'].':','twitter',$data);

if(lo3::is_admin() || lo3::is_market())
{
	$items[] = core_form::input_check('Allowed to sell products','allow_sell',$data);
	$items[] = core_form::header_nv('Organization Payment Methods');


}

echo(
	core_form::tab('orgtabs',
		core_form::table_nv(
			$items
		)
	)
);
*/
?>

<h3>Organization Info</h3>

<!--
<div class="alert note alert-info">
	<button type="button" class="close" data-dismiss="alert">×</button>
	<strong>What should I be doing here?</strong>
	<br />
	This is a placeholder for an inline tutorial using a jquery plugin (TBD). It may appear significantly different from this in our future release.
</div>
-->
<?=core_form::input_text('Organization','name',$data['name'],array('required' => true))?>
<!--
<div class="control-group">
	<label class="control-label" for="facebook">
		<?=$core->i18n['organizations:facebook']?>
		<i class="helpslug icon-question-sign" rel="popover" 
			data-title="<?=$core->i18n['organizations:facebook']?>" 
			data-content="If you have a Facebook account, enter your facebook page name here and we'll display your recent updates." />

	</label>
	<div class="controls">
		<div class="input-prepend">
			<span class="add-on">facebook.com/</span>
			<input type="text" name="facebook" value="<?=$data['facebook']?>" />
		</div>
	</div>
</div>
	
<div class="control-group">
	<label class="control-label" for="twitter">
		<?=$core->i18n['organizations:twitter']?>
		<i class="helpslug icon-question-sign" rel="popover" 
			data-title="<?=$core->i18n['organizations:twitter']?>" 
			data-content="If you have a Twitter account, enter the @name here and we'll display your recent tweets." />
	</label>
	<div class="controls">
		<div class="input-prepend">
			<span class="add-on">@</span>
			<input type="text" name="twitter" value="<?=$data['twitter']?>" />
		</div>
	</div>
</div>
-->

<div class="control-group"<?=$style?>>
	<label class="control-label" for="facebook">Facebook</label>
	<div class="controls">
		<div class="input-prepend">
		  	<span class="add-on">facebook.com/</span>
			<input type="text" name="facebook" class="input-small" value="<?=$data['facebook']?>" placeholder="Username">
		</div>
	</div>
</div>

<div class="control-group"<?=$style?>>
	<label class="control-label" for="twitter">Twitter</label>
	<div class="controls">
		<div class="input-prepend">
		  	<span class="add-on">@</span>
		  	<input type="text" name="twitter" class="input-large" value="<?=$data['twitter']?>" placeholder="Username">
		</div>
	</div>
</div>


<div class="control-group"<?=$style?>>
	<label class="control-label" for="twitter">Display Feed on Profile Page</label>
	<div class="controls">
		<select name="social_option_id">
			<option>None</option>
<?foreach ($social_options as $so) {?>
			<option value="<?=$so['social_option_id']?>"<?=$data['social_option_id']===$so['social_option_id']?'selected':''?>>
  				<?=$so['display_name']?>
  			</option>
<?}?>
		</select>
	</div>
</div>

<? if(lo3::is_admin() || lo3::is_market()): ?>
		
	<?= core_form::input_check('Allowed to sell products','allow_sell',$data['allow_sell'],array('popover'=>'Make this customer a Seller as well as a Buyer.')); ?>
	
	<h3>Organization Payment Methods</h3>

	<? if($domain['payment_allow_paypal'] == 1 || $data['payment_allow_paypal']): ?>
		<?= core_form::input_check('Allow Credit Card','payment_allow_paypal',$data['payment_allow_paypal'],array('popover'=>'Customers will pay up-front using PayPal credit processing.')); ?>
	<? endif; ?>

	<? if($domain['payment_allow_purchaseorder'] == 1 || $data['payment_allow_purchaseorder']): ?>
		<?= core_form::input_check('Allow Purchase Orders','payment_allow_purchaseorder',$data['payment_allow_purchaseorder'],array('popover'=>'Customers will create purchase orders, which they will then be invoiced for.')); ?>
	<? endif; ?>
	<? if($domain['payment_allow_ach'] == 1 || $data['payment_allow_ach']): ?>
		<?= core_form::input_check('Allow ACH','payment_allow_ach',$data['payment_allow_ach'],array('popover'=>'Customers can pay for their orders at checkout using ACH.')); ?>
	<? endif; ?>

<? endif; ?>


<? 
/*
if(lo3::is_admin() || lo3::is_market() || $data['org_id'] == $core->session['org_id']) 
{ 
	$users->load();
	if($users->__num_rows == 0)
	{
		echo(core_form::value('Payment Contact','<input type="hidden" name="payment_entity_id" value="0" />There are no users in this organization at this time. ',array('popover'=>'Choose who invoices and payment notifications will be sent to.')));
	}
	else
	{
		echo(core_form::input_select(
			'Payment Contact',
			'payment_entity_id',
			$data['payment_entity_id'],
			$users,
			array(
				'text_column'=>'full_name',
				'value_column'=>'entity_id',
				'default_show'=>true,
				'default_text'=>'No contact selected',
				'popover'=>'Choose who invoices and payment notifications will be sent to.',
			)
		));
	}
}
*/
?>

<?if(lo3::is_admin() || lo3::is_market()){?>

	<div<?=(($domain['payment_allow_purchaseorder'] == 1 || $data['payment_allow_purchaseorder'])?'':' style="display:none;"')?>>
	
		<div class="control-group">
			<label class="control-label" for="po_due_within_days">PO payments due</label>
			<div class="controls">
				<input type="text" class="input-mini" name="po_due_within_days" value="<?=intval($data['po_due_within_days'])?>" /> <span class="help-inline">days</span>
			</div>
		</div>

	</div>

<?}?>

<?if(lo3::is_admin()){?>

	<h3>Organization Options</h3>

	<div class="control-group">
		<label class="control-label" for="domain_id">Market</label>
		<div class="controls">
			<select name="domain_id" class="chzn-select" style="width: 270px;" data-placeholder="Choose a Market">
				<?=core_ui::options($all_domains,$data['domain_id'],'domain_id','name')?>
			</select>
			<span class="help-inline">Choose the market that this organization should be part of.</span>
		</div>
	</div>
		

		
<?}?>