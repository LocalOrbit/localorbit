<div class="row">
	<div class="span12">
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
$dds->add(new core_datacolumn('cycle','Delivery',true,'51%','<a href="Javascript:market.editDeliv(\'{dd_id}\');"><b>{formatted_cycle}</b><br />Deliver to: {formatted_address}</a>'));
$dds->add(new core_datacolumn('delivery_start_time','Delivery',true,'20%','<a href="Javascript:market.editDeliv(\'{dd_id}\');">{delivery_time}</a>'));
$dds->add(new core_datacolumn('pickup_start_time','Pickup',true,'20%','<a href="Javascript:market.editDeliv(\'{dd_id}\');">{pickup_time}</a>'));
$dds->add(new core_datacolumn('delivery_days.dd_id',core_ui::check_all('deliverydays'),false,'4%',core_ui::check_all('deliverydays','dd_id')));

$dds->size = (-1);
$dds->display_filter_resizer = false;
$dds->display_exporter_pager = false;
$dds->render_page_select = false;
$dds->render_page_arrows = false;

echo('<div id="delivTable">');
$dds->render();
echo('</div>');

?>
<div class="buttonset unlock_area pull-right" id="addDelivButton"<?=(($core->session['sec_pin'] == 1 || lo3::is_market())?'':' style="display:none;"')?>>
	<input type="button" class="btn btn-info" value="Add New Delivery Option" onclick="market.editDeliv(0);" />
	<input type="button" class="btn btn-danger" value="Remove Checked" onclick="market.removeCheckedDelives(this.form);" />
</div>
<br />

<fieldset id="editDeliv" style="display: none;">
	<legend>Delivery Info</legend>
	
	<div class="control-group">
		<label class="control-label">Cycle</label>
		<div class="controls">
			<select name="cycle" onchange="market.setOrdinalOptions();">
				<option value="weekly">Weekly</option>
				<option value="bi-weekly">Bi-weekly</option>
				<option value="monthly">Monthly (by day)</option>
				<option value="monthly-day">Monthly (by day #)</option>
			</select>
		</div>
	</div>
	
	<div class="control-group" id="delivery_ordinal_selector">
		<label class="control-label">Day Ordinal</label>
		<div class="controls">
			<select name="day_ordinal" id="day_ordinal">

			</select>
		</div>
	</div>
	
	<div class="control-group" id="day_selector">
		<label class="control-label">Day</label>
		<div class="controls">
			<select name="day_nbr">
				<option value="1">Monday</option>
				<option value="2">Tuesday</option>
				<option value="3">Wednesday</option>
				<option value="4">Thursday</option>
				<option value="5">Friday</option>
				<option value="6">Saturday</option>
				<option value="7">Sunday</option>
			</select>
		</div>
	</div>
	
	<div class="control-group" style="display: none;">
		<label class="control-label">Delivery fee</label>
		<div class="controls">
			<input type="text" name="amount" />
			<input type="hidden" name="devfee_id" />
		</div>
	</div>
	
	<div class="control-group" style="display: none;">
		<label class="control-label">Fee type</label>
		<div class="controls">
			 <select name="fee_calc_type_id">
				<?=core_ui::options(array(1 => 'Percentage', 2 => 'Dollar Amount'),null,'fee_calc_type_id','label')?>
             </select>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label">Order cutoff</label>
		<div class="controls">
			<select name="hours_due_before"><?=core_ui::options_seq('numbers',24,6,100,'',' hours before delivery')?></select>
		</div>
	</div>		
	
	<div class="control-group">
		<label class="control-label"></label>
		<div class="controls">
			<?=core_ui::checkdiv('allproducts','All products from sellers on this hub will deliver on this cycle.')?>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label"></label>
		<div class="controls">
			<?=core_ui::checkdiv('allcrosssellproducts','All cross-sell products from sellers on this hub will deliver on this cycle.')?>
		</div>
	</div>
	
	
	<h3>Seller drop off or delivery info</h3>
	<div class="control-group">
		<label class="control-label"><?=$core->i18n['field:delivery_days:seller_deliv_section']?></label>
		<div class="controls">
			<select name="deliv_address_id" id="deliv_address_id" onchange="market.setPickupLabel(this.selectedIndex);">
				<option value="0">Direct to customer</option>
				<?=core_ui::options($addresses,null,'address_id','label')?>
			</select>
		</div>
	</div>	
	
	
	<div class="control-group">
		<label class="control-label">Seller Delivery Start</label>
		<div class="controls">
			<?=core_ui::time_picker('delivery_start_time')?>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label">Seller Delivery End</label>
		<div class="controls">
			<?=core_ui::time_picker('delivery_end_time')?>
		</div>
	</div>
	
	
	<h3><?=$core->i18n['field:delivery_days:buyer_deliv_section']?></h3>	
	<div class="control-group">
		<label class="control-label">Buyer Pick up location</label>
		<div class="controls">
			<select name="pickup_address_id" id="pickup_address_id">
				<option value="0">Delivered to Buyer from Hub</option>
				<?=core_ui::options($addresses,null,'address_id','label')?>
			</select>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label">Buyer Pick up Start</label>
		<div class="controls">
			<?=core_ui::time_picker('pickup_start_time',0,0,24,'half')?>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label">Buyer Pick up End</label>
		<div class="controls">
			<?=core_ui::time_picker('pickup_end_time',0,0,24,'half')?>
		</div>
	</div>
	
	<input type="hidden" name="dd_id" value="" />
	<input type="hidden" name="devfee_id" value="" />
	<div class="form-actions buttonset">
		<input type="button" class="btn btn-warning" value="cancel" onclick="market.cancelDelivChanges();" />
		<input type="button" class="btn btn-primary" value="save this delivery option" onclick="market.saveDeliv();" />
	</div>
</fieldset>
	</div>
</div>
