<?php
lo3::require_permission();
lo3::require_login();



global $data,$core;


if(!$data)
	$data = core::model('domains')->load();

if(!in_array($data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
	lo3::require_orgtype('admin');
else
	lo3::require_orgtype('market');


$col = core::model('delivery_days')->collection()->filter('domain_id',$data['domain_id']);
foreach($col as $item)
{
	$item->next_time();
}
$addresses = $data->get_addresses();

core::js('core.delivery_days='.json_encode($col->to_hash('dd_id')).';');
#core::log('delivery day josn: '.$core->response['js']);
$dds = new core_datatable('delivery_days','market/delivery?domain_id='.$core->data['domain_id'],$col);
$dds->add(new core_datacolumn('delivery_days.dd_id',core_ui::check_all('deliverydays'),false,'4%',core_ui::check_all('deliverydays','dd_id')));
$dds->add(new core_datacolumn('cycle','Delivery',true,'51%','<a href="Javascript:market.editDeliv(\'{dd_id}\');"><b>{formatted_cycle}</b><br />Deliver to: {formatted_address}</a>'));
$dds->add(new core_datacolumn('delivery_start_time','Delivery',true,'20%','<a href="Javascript:market.editDeliv(\'{dd_id}\');">{delivery_time}</a>'));
$dds->add(new core_datacolumn('pickup_start_time','Pickup',true,'20%','<a href="Javascript:market.editDeliv(\'{dd_id}\');">{pickup_time}</a>'));

$dds->size = (-1);
$dds->display_filter_resizer = false;
$dds->render_page_select = false;
$dds->render_page_arrows = false;
$dds->render();

?>
<div class="buttonset unlock_area" id="addDelivButton"<?=(($core->session['sec_pin'] == 1 || lo3::is_market())?'':' style="display:none;"')?>>
	<input type="button" class="button_secondary" value="Add New Delivery Option" onclick="market.editDeliv(0);" />
	<input type="button" class="button_secondary" value="Remove Checked" onclick="market.removeCheckedDelives(this.form);" />
</div>
<br />

<fieldset id="editDeliv" style="display: none;">
	<legend>Delivery Info</legend>
	<table class="form">
		<tr>
			<td class="label">Cycle</td>
			<td class="value">
				<select name="cycle" onchange="market.setOrdinalOptions();">
					<option value="weekly">Weekly</option>
					<option value="bi-weekly">Bi-weekly</option>
					<option value="monthly">Monthly (by day)</option>
					<option value="monthly-day">Monthly (by day #)</option>
				</select>
			</td>
		</tr>
		<tr style="display: none;" id="delivery_ordinal_selector">
			<td class="label">Day Ordinal</td>
			<td class="value">
				<select name="day_ordinal" id="day_ordinal">

				</select>
			</td>
		</tr>
		<tr id="day_selector">
			<td class="label">Day</td>
			<td class="value">
				<select name="day_nbr">
					<option value="1">Monday</option>
					<option value="2">Tuesday</option>
					<option value="3">Wednesday</option>
					<option value="4">Thursday</option>
					<option value="5">Friday</option>
					<option value="6">Saturday</option>
					<option value="7">Sunday</option>
				</select>
			</td>
		</tr>
		<tr style="display: none;">
			<td class="label">Delivery fee</td>
			<td class="value">
				<input type="text" name="amount" />
				<input type="hidden" name="devfee_id" />
			</td>
		</tr>
		<tr style="display: none;">
			<td class="label">Fee type</td>
			<td class="value">
               <select name="fee_calc_type_id">
					<?=core_ui::options(array(1 => 'Percentage', 2 => 'Dollar Amount'),null,'fee_calc_type_id','label')?>
               </select>
			</tr>
		</tr>
		<tr>
			<td class="label">Order cutoff</td>
			<td class="value"><select name="hours_due_before"><?=core_ui::options_seq('numbers',24,6,100,'',' hours before delivery')?></select></td>
		</tr>
		<tr>
         <td/>
			<td class="value"><?=core_ui::checkdiv('allproducts','All products from sellers on this hub will deliver on this cycle.')?></td>
		</tr>
		<tr>
         <td/>
			<td class="value"><?=core_ui::checkdiv('allcrosssellproducts','All cross-sell products from sellers on this hub will deliver on this cycle.')?></td>
		</tr>
		<tr>
			<td colspan="2"><h3>Seller drop off or delivery info</h3></td>
		</tr>
		<tr>
			<td class="label"><?=$core->i18n['field:delivery_days:seller_deliv_section']?></td>
			<td class="value">
				<select name="deliv_address_id" onchange="market.setPickupLabel(this.selectedIndex);">
					<option value="0">Direct to customer</option>
					<?=core_ui::options($addresses,null,'address_id','label')?>
				</select>
			</td>
		</tr>
		<tr>
			<td class="label">Seller Delivery Start</td>
			<td class="value">
				<?=core_ui::time_picker('delivery_start_time')?>
			</td>
		</tr>
		<tr>
			<td class="label">Seller Delivery End</td>
			<td class="value">
				<?=core_ui::time_picker('delivery_end_time')?>
			</td>
		</tr>
		<tr id="pickup_header">
			<td colspan="2"><h3><?=$core->i18n['field:delivery_days:buyer_deliv_section']?></h3></td>
		</tr>
		<tr id="pickup_label3">
			<td class="label">Buyer Pick up location</td>
			<td class="value">
				<select name="pickup_address_id">
					<option value="0">Delivered to Buyer from Hub</option>
					<?=core_ui::options($addresses,null,'address_id','label')?>
				</select>
			</td>
		</tr>
		<tr id="pickup_label1">
			<td class="label">Buyer Pick up Start</td>
			<td class="value"><?=core_ui::time_picker('pickup_start_time',0,0,24,'half')?></td>
		</tr>
		<tr id="pickup_label2">
			<td class="label">Buyer Pick up End</td>
			<td class="value"><?=core_ui::time_picker('pickup_end_time',0,0,24,'half')?></td>
		</tr>
	</table>
	<input type="hidden" name="dd_id" value="" />
	<input type="hidden" name="devfee_id" value="" />
	<div class="buttonset">
		<input type="button" class="button_secondary" value="save this delivery option" onclick="market.saveDeliv();" />
		<input type="button" class="button_secondary" value="cancel" onclick="market.cancelDelivChanges();" />
	</div>
</fieldset>
