<?php

$payable_ids_string = "'" . str_replace(",", "','", $core->data['payable_ids']) . "'";

$sql="
	select distinct organizations.name as name, 
		organizations.org_id,
		concat(payables.from_org_id, '-', payables.to_org_id) as group_key,
		group_concat(distinct(payables.payable_id) separator ',') as payable_ids
	from payables inner join organizations on organizations.org_id = payables.to_org_id
	where payables.payable_id in (". $payable_ids_string.")
			and payables.from_org_id = ".$core->session['org_id']."
	group by payables.from_org_id, payables.to_org_id  
	order by organizations.name";

$sellers = new core_collection($sql);
?>


<?php 
foreach($sellers as $seller) {
	$payment_total = 0;
?>


	<div class="row <?=$core->data['tab']?>_row"" id="<?=$core->data['tab']?>__area__<?=$seller['group_key']?>">
		<div class="span6">
			<table class="dt" style="width:100%;" width="100%">
				<?php 
					$sql = "
						select distinct 
							lo_order.lo3_order_nbr,
							lo_order_line_item.product_name, 
							lo_order_line_item.qty_delivered,
							payables.amount
						from payables inner join organizations on organizations.org_id = payables.to_org_id
							inner join lo_order on lo_order.lo_oid = payables.lo_oid
							inner join lo_order_line_item on lo_order_line_item.lo_liid = payables.lo_liid
						where payables.payable_id in (". $seller['payable_ids'].")
							and payables.from_org_id = ".$core->session['org_id']."
						order by lo_order.lo3_order_nbr, lo_order_line_item.product_name";

					$payable_list = new core_collection($sql);					
					$html = "";
					
					// header
					$html = $html."<tr>";
						$html = $html."<td colspan='3'><h2><i class='icon-cart'>&nbsp;</i>".$seller['name']."</h2></td>";
					$html = $html."</tr>";
					$html = $html."<tr>";
						$html = $html."<th class='dt'>Order Number</th>";
						$html = $html."<th class='dt'>Description</th>";
						$html = $html."<th class='dt'>Amount Paid</th>";
					$html = $html."</tr>";
				
					// invoices
					foreach($payable_list as $payable){	
						$payment_total += $payable['amount'];
						
						$html = $html."<tr>";
							$html = $html. "<td class='dt'>".$payable['lo3_order_nbr']."</td>";
							$html = $html. "<td class='dt'>".$payable['product_name']." (".$payable['qty_delivered'].")</td>";
							$html = $html."<td class='dt' align='right'>".core_format::price($payable['amount'],false)."</td>";
						$html = $html."</tr>";
					}
					
										
					// total
					$html = $html."<tr><td><hr></td><td><hr></td><td><hr></td></tr>";
					$html = $html."<tr>";
						$html = $html."<td></td>";
						$html = $html."<td align='right'><b>Total Due: ".core_format::price($payment_total)."</b></td>";
					$html = $html."</tr>";
					
					echo $html;
				?>
			</table>
		</div>		
			
			
		<div class="span6">
			<h2><i class="icon-coins">&nbsp;</i>Method</h2>			
			<input type="hidden" name="<?=$core->data['tab']?>__group_total__<?=$seller['group_key']?>" value="<?=$payment_total?>" />
			<input type="hidden" name="<?=$core->data['tab']?>__payable_ids__<?=$seller['group_key']?>" value="<?=$sellers['payable_ids']?>" />
			<?php 
				$this->payment_method_selector($core->data['tab'],$seller['from_org_id'],$seller['to_org_id'],$seller['group_key']);
			?>
						
		</div>	
		
		<br /><br />
	</div>
<?php 
}

core::replace('payments_actions');
core::js("$('#payments_list, #payments_actions').toggle(300);");
?>







