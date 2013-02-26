<?php
core::clear_response('replace','left');
core::clear_response('replace','center');
core::replace('left','&nbsp;&nbsp;');
core::ensure_navstate(array('left'=>'left_blank'));
core::head('Customers');
lo3::require_permission();
?>

<table>
	<col width="300" />
	<col width="55" /> 
	<col width="340" />
	<col width="15" />
	<col width="340" />
	<col width="15" />
	<tr>
		<td style="vertical-align: top;padding-left: 20px;">
			<div class="homepage_message">
				Flexible, localized tools designed to help people build healthier communities through better food.
				<br />&nbsp;<br />
				<a href="http://localorbit.zendesk.com/anonymous_requests/new" target="_blank" class="homepage_learnmore">&raquo; request a demo</a>
			</div>
		</td>
		<td>&nbsp;</td>
		<td class="homepage">
			<h1 class="homepage">By State</h1>
			Maryland     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Farm Alliance of Baltimore City<br /><br />
			Michigan     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detroit Eastern Market<br /><br /><br />
			New Mexico     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Albuquerque Fresh<br /><br /><br />
			Pennsylvania     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Apple Ridge Farm<br /><br /><br />
			Washington     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Farm to Table (Seattle)
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Skagit County
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Willowood Farm (Seattle)t<br /><br /><br />
		</td>
		<td>&nbsp;</td>
		<td class="homepage">
			<h1 class="homepage">By Solution</h1>
			Producer Groups     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Apple Ridge Farm (City, PA)
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Farm Alliance of Baltimore City
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Willowood Farm (Seattle)<br /><br />
			Distributors     
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Albuquerque Fresh<br /><br />		
			Food Hubs  
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detroit Eastern Market
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Farm to Table (Seattle)
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Skagit County<br /><br />
			Farmers 
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Apple Ridge Farm
			<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Willowood Farm (Seattle)<br /><br />
		</td>
		<td>&nbsp;</td>
	</tr>
</table>

<?php core::replace('full_width');?>