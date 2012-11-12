<?
global $data,$domains,$all_domains;
$domain = core::model('domains')->load($data['domain_id']);
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
<div class="tabarea" id="orgtabs-a1">
	<table class="form">
		<tr>
			<td class="label">Name</td>
			<td class="value"><input type="text" name="name" value="<?=$data['name']?>" /></td>
		</tr>
		<tr>
			<td class="label"><?=$core->i18n['organizations:facebook']?></td>
			<td class="value"><input type="text" name="facebook" value="<?=$data['facebook']?>" /></td>
		</tr>
		<tr>
			<td class="label"><?=$core->i18n['organizations:twitter']?></td>
			<td class="value"><input type="text" name="twitter" value="<?=$data['twitter']?>" /></td>
		</tr>
		<?if(lo3::is_admin() || lo3::is_market()){?>
		<tr>
			<td class="label">&nbsp;</td>
			<td class="value"><?=core_ui::checkdiv('allow_sell','Allowed to sell products',$data['allow_sell'])?></td>
		</tr>
		
		<tr>
			<td colspan="2"><h3>Organization Payment Methods</h3></td>
		</tr>
		<tr<?=(($domain['payment_allow_paypal'] == 1 || $data['payment_allow_paypal'])?'':' style="display:none;')?>>
			<td class="label">&nbsp;</td>
			<td class="value"><?=core_ui::checkdiv('payment_allow_paypal','Allow CC via Paypal',$data['payment_allow_paypal'])?></td>
		</tr>
		<tr<?=(($domain['payment_allow_purchaseorder'] == 1 || $data['payment_allow_purchaseorder'])?'':' style="display:none;')?>>
			<td class="label">&nbsp;</td>
			<td class="value"><?=core_ui::checkdiv('payment_allow_purchaseorder','Allow Purchase Orders',$data['payment_allow_purchaseorder'])?></td>
		</tr>
		<?}?>
		
		<?if(lo3::is_admin()){?>
		<tr>
			<td colspan="2"><h3>Organization Options</h3></td>
		</tr>
		<tr>
			<td class="label">Hub</td>
			<td class="value">
				<select name="domain_id">
					<?=core_ui::options($all_domains,$data['domain_id'],'domain_id','name')?>
				</select>
			</td>
		</tr>

		<tr>
			<td class="label">Buyer Type</td>
			<td class="value">
				<select name="buyer_type">
					<?=core_ui::options(array('Wholesale'=>'Wholesale','Retail'=>'Retail'),$data['buyer_type'])?>
				</select>
			</td>
		</tr>
		<?}?>
	</table>
	<? $this->activate_enable(); ?>
</div>