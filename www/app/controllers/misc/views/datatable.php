<div class="notification" onclick="$(this).fadeOut();" id="notification_area">
	<img src="/lo3/img/default/notification_warning.png" />
	Your profile has been saved.
</div>
<? 
core::js('window.setTimeout("$(\'#notification_area\').fadeOut();",5000);');

?>
<h1>Customers</h1>
<table class="dt" id="dttest">
	<tr>
		<td class="dt_filter_resizer" colspan="3">
			<div class="dt_filter" id="dttest_filters">
				<a href="Javascript:core.ui.dataTable.filterToggle('dttest');"><img src="<?=image('expandable')?>"></a>
				<select>
					<option>Show All User Types</option>
					<option>Show Only Buyers</option>
					<option>Show Only Sellers</option>
					<option>Show Only Market Managers</option>
					<option>Show Only CSRs</option>
				</select>
				<br />
				<select>
					<option>All Hubs</option>
					<option>Only Springfield</option>
					<option>Only Test of Michigan</option>
					<option>Only Benzie</option>
					<option>Only Detroit Eastern Market</option>
				</select>
				<br />
				Joined after: <?=core_ui::date_picker('test_date')?>
			</div>
			<div class="dt_resizer">
				<select>
					<option>Showing: 10</option>
					<option>Showing: 50</option>
					<option>Showing: 100</option>
					<option>Showing: All</option>
				</select>
			</div>
		</td>
	</tr>
	<tr>
		<th class="dt dt_sortable dt_sort_asc">Name</th>
		<th class="dt dt_sortable">Email</th>
		<th class="dt dt_sortable">Last Login</th>
	</tr>
	<tr class="dt">
		<td class="dt">Mike Thorn</td>
		<td class="dt">mike@localorb.it</td>
		<td class="dt">July 1, 2012</td>
	</tr>
	<tr class="dt1">
		<td class="dt">Julie Mills</td>
		<td class="dt">julie@localorb.it</td>
		<td class="dt">Feb 12, 2011</td>
	</tr>
	<tr class="dt">
		<td class="dt">Erika Block</td>
		<td class="dt">erika@localorb.it</td>
		<td class="dt">Nov 30, 2015</td>
	</tr>
	<tr class="dt1">
		<td class="dt">Mariah Cherem</td>
		<td class="dt">mariah@localorb.it</td>
		<td class="dt">Sept 5, 2014</td>
	</tr>
	<tr class="dt">
		<td class="dt">Ragan Erickson</td>
		<td class="dt">ragan@localorb.it</td>
		<td class="dt">Apr 15, 2013</td>
	</tr>
	<tr>
		<td class="dt_exporter_pager" colspan="3">
			<div class="dt_exporter">
				&nbsp;<img src="<?=image('disk')?>" /> Download .csv / .pdf / .xlsx
			</div>
			<div class="dt_pager">
				|&lt;&nbsp;&laquo;&nbsp;
				<select>
					<option>Page 1 of 3</option>
					<option>Page 2 of 3</option>
					<option>Page 3 of 3</option>
				</select>
				&nbsp;&raquo;&nbsp;&gt;|
			</div>
		</td>
	</tr>
</table>
<br />&nbsp;<br />