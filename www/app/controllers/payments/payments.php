<?php

class core_controller_payments extends core_controller
{
}

function org_amount ($data) {
   global $core;

   $amount_field = isset($data['amount'])?'amount':'amount_due';
   if ($data['to_org_id'] == $core->session['org_id']) {
      $data['org_name'] = $data['from_org_name'];
      $data['hub_name'] = $data['from_domain_name'];
      $sign = 1;
      $data['in_amount'] = $data[$amount_field];
      $data['out_amount'] = 0;
   } else {
      $data['org_name'] = $data['to_org_name'];
      $data['hub_name'] = $data['to_domain_name'];
      $sign = -1;
      $data['in_amount'] = 0;
      $data['out_amount'] = $data[$amount_field];
   }

   $data['amount_value'] = $sign * $data[$amount_field ];

   return $data;
}

function payable_desc ($data) {
   if (empty($data['description'])) {
      if (strcmp($data['payable_type'],'buyer order') == 0) {
         $data['description'] = $data['buyer_order_identifier'];
         $data['description_html'] = $data['buyer_order_identifier'];
      } else if ($data['payable_type'] == 'seller order') {
         $data['description_html'] = $data['seller_order_identifier'];
      } else if ($data['payable_type'] == 'hub fees') {
         $data['description_html'] = 'Hub Fees';
      }
   } else {
      $data['description_html'] = $data['description'];
   }

   if ($data['is_invoiced']) {
      $data['invoice_status'] = 'Invoiced';
   } else if ($data['invoicable']) {
      $data['invoice_status'] = 'Invoicable';
   } else {
      $data['invoice_status'] = 'Pending';
   }

   return $data;
}

function payable_info ($data) {
   $payable_info = array_map(function ($item) { return explode('|',$item); }, explode('$$', $data['payable_info']));

   if (count($payable_info) == 1) {
      $info = $payable_info[0];
      $data['description'] = format_text($info);
      $data['description_html'] = format_html($info);
   } else {
      $data['description'] = '';
      $data['description_html'] = format_html_header($payable_info);

      for ($index = 0; $index < count($payable_info); $index++) {
         $info = $payable_info[0];

         $data['description'] .= (($index>0)?', ':'') . format_text($info);
         $data['description_html'] .= (($index>0)?'<br/>':'') .format_html($info);
      }

      $data['description_html'] .= '</div>';
   }
   return $data;
}

function format_html_header ($payable_info) {
   $title = '';

   if (stripos($payable_info[0][0], 'order') >= 0) {
      $title = 'Orders';
   } else if (stripos($payable_info[0][0], 'hub fees') >= 0) {
      $title = 'Fees';
   } else {
      $title = $payable_info[0][0];
   }

   $id = str_replace(' ', '_', $payable_info[0][0]) . '_' . $payable_info[0][1];
   return '<a href="#!payments-demo" onclick="$(\'#' . $id . '\').toggle();">' . $title . '</a><div id="' . $id .'" style="display: none;">';
}

function format_html ($info) {
   $text = '';
   if (count($info) > 0) {
      if (strcmp($info[0],'buyer order') == 0) {
         $text .= '<a href="#!orders-view_order--lo_oid-' . $info[1] . '">';
         $text .= 'Order #' . $info[1];
         $text .= '</a>';
      } else if ($info[0] === 'seller order') {
         $text .= 'Seller Order #' . $info[1];
      } else if ($info[0] === 'hub fees') {
         $text .= 'Hub Fees';
      } else {
         $text .= $info[0];
         if (count($info) > 1) {
            $text .= ' #' . $info[1];
         }
      }
   }
   return $text;
}

function format_text ($info) {
   $text = '';
   if (count($info) > 0) {
      if (strcmp($info[0],'buyer order') == 0) {
         $text .= 'Order #' . $info[1];
      } else if ($info[0] === 'seller order') {
         $text .= 'Seller Order #' . $info[1];
      } else if ($info[0] === 'hub fees') {
         $text .= 'Hub Fees';
      } else {
         $text .= $info[0];
         if (count($info) > 1) {
            $text .= ' #' . $info[1];
         }
      }
   }
   return $text;
}

?>
