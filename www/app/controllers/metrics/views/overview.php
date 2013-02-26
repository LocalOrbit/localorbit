<?
global $core;
core_ui::load_library('js','metrics.js');
lo3::require_orgtype('admin');
core::ensure_navstate(array('left'=>'left_dashboard'),'metrics-overview','reports');
core::head('Metrics','This page is used to view various metrics');

$values = $this->default_values();
$domains = core::model('domains')->collection()->filter('domain_id','not in',array(1,3,6,23,24,25,26))->sort('name');

?>
<div id="unlock_area"<?=((intval($core->session['sec_pin']) == 1)?' style="display:none;"':'')?>>
	<form name="permissions" method="post" onsubmit="return core.submit('/auth/unlock_pin',this);">
		<h1>Security Check</h1>
		<table class="form">
			<tr>
				<td class="label">4 Digit Pin:</td>
				<td class="value"><input type="password" name="sec_pin" value="" /></td>
			</tr>
		</table>
		<div class="buttonset">
			<input type="submit" class="button_primary" value="unlock" />
		</div>
		<input type="hidden" name="custom_unlock_area" value="all_metrics" />
		<input type="hidden" name="formname" value="permissions" />
	</form>
</div>
<div id="all_metrics"<?=((intval($core->session['sec_pin']) != 1)?' style="display:none;"':'')?>>
	<h1>Metrics</h1>
	<form name="metricsForm">
		<?=core_ui::tab_switchers('metricstabs',array('Metrics Filters and Options','Data Dumps'))?>
		<div class="tabarea" id="metricstabs-a1">
			<table class="form">
				<tr>
					<td class="label">Start Date:</td>
					<td class="value"><?=core_ui::date_picker('start_date',$values['start_date'])?></td>
				</tr>
				<tr>
					<td class="label">End Date:</td>
					<td class="value"><?=core_ui::date_picker('end_date',$values['end_date'])?></td>
				</tr>
				<tr>
					<td class="label">Hub:</td>
					<td class="value">
						<select name="domain_id">
							<option value="0">All Hubs</option>
							<?=core_ui::options($domains,$values['domain_id'],'domain_id','name')?>
						</select>
					</td>
				</tr>
				<tr>
					<td class="label">Breakdown By:</td>
					<td class="value">
						<select name="breakdown_by">
							<option value="day">Day</option>
							<option value="week" selected="selected">Week</option>
							<option value="month">Month</option>
						</select>
					</td>
				</tr>
			</table>
			<div class="error">Note: if you select a day in the middle of a month, the entire month's data is used for calculation. This also applies to weeks. </div>
			<div class="buttonset">
				<input type="button" class="button_secondary" value="download as csv" onclick="core.metrics.downloadCsv();" />
				<input type="button" class="button_secondary" value="refresh data" onclick="core.metrics.refreshData();" />
			</div>
			<input type="hidden" name="output_as" value="html" />
			<br />
			<div id="output_area">

			</div>
		</div>
		<div class="tabarea" id="metricstabs-a2">
			This tab shows data dumps for the last 10 days. Data is kept much longer than 10 days, but is not yet available. This exists only to assist in verifying that the data is being recorded properly. 
			<br />
			<h2>Product Data</h2>
			<a href="app/metrics/download_products_dump?day=0">Today</a><br/>
			<a href="app/metrics/download_products_dump?day=1">1 day before today</a><br/>
			<a href="app/metrics/download_products_dump?day=2">2 days before today</a><br/>
			<a href="app/metrics/download_products_dump?day=3">3 days before today</a><br/>
			<a href="app/metrics/download_products_dump?day=4">4 days before today</a><br/>
			<a href="app/metrics/download_products_dump?day=5">5 days before today</a><br/>
			<a href="app/metrics/download_products_dump?day=6">6 days before today</a><br/>
			<a href="app/metrics/download_products_dump?day=7">7 days before today</a><br/>
			<h2>Product Prices Data</h2>
			<a href="app/metrics/download_product_prices_dump?day=0">Today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=1">1 day before today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=2">2 days before today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=3">3 days before today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=4">4 days before today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=5">5 days before today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=6">6 days before today</a><br/>
			<a href="app/metrics/download_product_prices_dump?day=7">7 days before today</a><br/>
			
			<h2>Sales Data</h2>
			<a href="app/metrics/download_sales_dump?day=0">Today</a><br/>
			<a href="app/metrics/download_sales_dump?day=1">1 day before today</a><br/>
			<a href="app/metrics/download_sales_dump?day=2">2 days before today</a><br/>
			<a href="app/metrics/download_sales_dump?day=3">3 days before today</a><br/>
			<a href="app/metrics/download_sales_dump?day=4">4 days before today</a><br/>
			<a href="app/metrics/download_sales_dump?day=5">5 days before today</a><br/>
			<a href="app/metrics/download_sales_dump?day=6">6 days before today</a><br/>
			<a href="app/metrics/download_sales_dump?day=7">7 days before today</a><br/>
			<br />
			<div class="buttonset">
				<input type="button" class="button_secondary" value="perform dumps" onclick="core.doRequest('/metrics/do_dump',{})" />
			</div>
			<br />&nbsp;<br />
		</div>
	</form>
	<br />&nbsp;<br />
</div>
