<?php

/* select distinct
	organizations.org_id,
	organizations.name,
	invoices.invoice_num,
	lo_order_line_item.product_name,
	payables.payable_type,
	payables.amount
	
	from lo_order INNER JOIN invoices ON lo_order.lo_oid = invoices.lo_oid
	INNER JOIN organizations ON organizations.org_id = lo_order.org_id
	INNER JOIN payables ON  payables.lo_oid = lo_order.lo_oid
	LEFT JOIN lo_order_line_item ON payables.lo_liid = lo_order_line_item.lo_liid
	where payables.payable_id in (0,". explode(',',$core->data['invoice_nums']).")";

 */
$invoice_num_string = "'" . str_replace(",", "','", $core->data['invoice_nums']) . "'";

$sql="
	select distinct	from_org.name as from_org_name, to_org.name as to_org_name, 
		payables.from_org_id,	payables.to_org_id, 
		invoices.invoice_num, SUM(payables.amount) as amount,		
		(lo_order.grand_total + lo_order.adjusted_total - lo_order.item_total) AS shipping_total,
		lo_order.adjusted_total AS flat_discount,
		concat(payables.from_org_id, '-', payables.to_org_id) as group_key,
		group_concat(distinct(lo_order.lo_oid) separator ',') as lo_oids
	from lo_order INNER JOIN invoices ON lo_order.lo_oid = invoices.lo_oid
		INNER JOIN payables ON payables.lo_oid = lo_order.lo_oid
		INNER JOIN organizations from_org ON from_org.org_id = payables.from_org_id
		INNER JOIN organizations to_org ON to_org.org_id = payables.to_org_id
	where payables.payable_type IN ('buyer order', 'delivery fee')
		and payables.from_org_id != 1
		and payables.to_org_id != 1
		and invoices.invoice_num in (". $invoice_num_string.")
	    and payables.to_org_id = ".$core->session['org_id']."
	group by payables.from_org_id, payables.to_org_id
	order by from_org.name,	to_org.name";

$invoices_to_receive = new core_collection($sql);
?>


<?php 
foreach($invoices_to_receive as $invoice_to_receive) {
	$payable_ids = array();	
	$payment_total = 0;
?>
	<div class="row" id="<?=$core->data['tab']?>__area__<?=$invoice_to_receive['group_key']?>">
		<div class="span6">
			<table class="dt" style="width:100%;" width="100%">
				<?php 
					$sql = "
						SELECT
							invoices.invoice_num,				
             				SUM(payables.amount) AS amount,
							group_concat(distinct(payables.payable_id) separator ',') as payable_ids
						FROM payables INNER JOIN lo_order ON payables.lo_oid = lo_order.lo_oid
							INNER JOIN invoices ON lo_order.lo_oid = invoices.lo_oid
						WHERE payables.payable_type IN('delivery fee', 'buyer order')
							AND payables.amount != 0
							AND payables.to_org_id = ".$core->session['org_id']." 
							AND lo_order.lo_oid in (".$invoice_to_receive['lo_oids'].")
						GROUP BY invoices.invoice_num
						ORDER BY invoices.invoice_num DESC";
							
					$payable_list = new core_collection($sql);					
					$html = "";
					
					// header
					$html = $html."<tr>";
						$html = $html."<td colspan='3'><h2><i class='icon-cart'>&nbsp;</i>From ".$invoice_to_receive['from_org_name']." to ".$invoice_to_receive['to_org_name']."</h2></td>";
					$html = $html."</tr>";
					$html = $html."<tr>";
						$html = $html."<th class='dt'>Invoice #</th>";
						$html = $html."<th class='dt'>Amount Due".$payable['payable_type']."</th>";
					$html = $html."</tr>";
				
					// invoices
					foreach($payable_list as $payable){	
						$payment_total += $payable['amount'];
						$payable_ids[] = $payable['payable_ids'];
						
						$html = $html."<tr>";
							$html = $html. "<td class='dt'>".$payable['invoice_num']."</td>";
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
			<input type="hidden" name="<?=$core->data['tab']?>__group_total__<?=$invoice_to_receive['group_key']?>" value="<?=$payment_total?>" />
			<input type="hidden" name="<?=$core->data['tab']?>__payable_ids__<?=$invoice_to_receive['group_key']?>" value="<?=implode(',',$payable_ids)?>" />
			<?php 
				$this->payment_method_selector($core->data['tab'],$invoice_to_receive['from_org_id'],$invoice_to_receive['to_org_id'],$invoice_to_receive['group_key']);
			?>
						
		</div>	
		
		<br /><br />
	</div>
<?php 
}

core::replace('enter_receipts_actions');
core::js("$('#enter_receipts_list, #enter_receipts_actions').toggle(300);");
?>







