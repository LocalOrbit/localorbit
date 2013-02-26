<?
$to_email = $core->view[0];
$values = array(
   'org_name'=>$core->view[1],
   'amount_overdue'=>$core->view[2],
   'domain_id'=>$core->view[3],
   'hubname'=>$core->view[4]
);

#core::log('email values: '.print_r($values,true));

$body  = $this->email_start();
/*

# we need to generate the html for the items table in the email
$item_html = '
   <table class="dt">

';

$counter = false;
$cur_seller = '';
$is_first = true;
foreach($values['items'] as $item)
{
   if($cur_seller != $item['seller_name'])
   {
      $cur_seller = $item['seller_name'];
      $item_html .= '
         <tr>
            <th class="dt">'.$item['seller_name'].'</th>
      ';

      if($is_first)
      {
         $item_html .= '
            <th class="dt">Quantity</th>
            <th class="dt">Unit Price</th>
            <th class="dt">Subtotal</th>
         ';
      }
      else
      {
         $item_html .= '
            <th class="dt" colspan="3">&nbsp;</th>
         ';
      }

      $item_html .= '</tr>';

      $is_first = false;
   }
   $item_html .= '
      <tr class="dt'.$counter.'">
         <td class="dt">'.$item['product_name'].'</td>
         <td class="dt">'.$item['qty_ordered'].' '.$item['unit_plural'].'</td>
         <td class="dt">'.core_format::price($item['unit_price']).'</td>
         <td class="dt">'.core_format::price($item['row_total']).'</td>
      </tr>
   ';
   $counter = (!$counter);
}

$item_html .= '</table>';

$values['items'] = $item_html;
*/
$body .= $this->handle_source($core->session['i18n']['email:suspend_mm'],$values);

$body .= $this->footer();
$body .= $this->email_end();
/*
$this->send_email(
   'Organization \'' . $values['org_name'] . '\' has been suspended for an overdue balance.',
   $to_email,
   $body,
   array(),
   $core->config['mailer']['From'],
   $values['hubname']
);
*/
$mm_emails = array();
$mm_emails = core::model('domains')->get_mm_emails($values['domain_id']);
if(count($mm_emails) > 0)
{
   # send the MM notification
   $body  = $this->email_start();
   $body .= $this->handle_source($core->session['i18n']['email:suspend_mm'],$values);
   $body .= $this->footer();
   $body .= $this->email_end();

   $this->send_email(
      'Organization \'' . $values['org_name'] . '\' has been suspended for an overdue balance.',
      implode(',',$mm_emails),
      $body,
      array(),
      $core->config['mailer']['From'],
      $values['hubname']
   );
}

?>