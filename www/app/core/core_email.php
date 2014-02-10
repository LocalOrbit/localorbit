<?
class core_email
{
  public static function send($subject,$to,$body='',$cc=array(),$from_email='',$from_name='',$merge_vars='')
  {
    global $core;

    # check to see if we're forcing this email to go to a particular address
    if(isset($core->data['force_email']) && $core->data['force_email']!='')
      $to = $core->data['force_email'];

    if($from_email == '')
    {
      $from_email = $core->config['mailer']['From'];
    }
    if($from_name == '')
    {
      $from_name = $core->config['mailer']['FromName'];
    }

    # Previously this functionality used phpmailer.
    # Now we're just going to write it to the db
    $email = core::model('sent_emails');
    $email['subject'] = $subject;
    $email['body'] = $body;

    if(is_array($to))
      $email['to_address'] = implode(',',$to);
    else
      $email['to_address'] = $to;

    $email['from_email'] = $from_email;
    $email['from_name']  = $from_name;
    $email['emailstatus_id'] = 1;

    if(is_array($merge_vars))
      $email['merge_vars'] = serialize($merge_vars);

    $email->save();
  }

  public static function header($domain_id=null) {
    global $core;

    if (!is_null($domain_id)) {
      $domain =  core::model('domains')->load($domain_id);
      $tagline = '&quot;'.$domain['custom_tagline'].'&quot;';
    } else {
      $tagline = '';
    }

    return '<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Email</title>
</head>
<body style="background: #e5e5e5; padding: 0; margin: 0;">
  <style>
    body {
      padding: 0;
      margin: 0
      color: #666;
      background: #e5e5e5;
    }
    a {
      color: #6e0206;
      text-decoration: none;
    }
    h1 {
      font: bolder 22px/1.5 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    h2 {
      margin: 0;
      font: lighter 24px/1.25 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    h3 {
      margin: 0;
      font: bold 16px/1.875 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    dl {
      margin: 0;
    }
    dt {
      display: inline;
    }
    dd {
      display: inline;
      margin: 0;
      font-weight: bold;
    }
    th dl {
      display: inline-block;
      margin: 0;
      vertical-align: middle;
    }
    th dt {
      display: block;
      color: #6e0206;
      font: normal 18px/1.666 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    th dd {
      display: inline;
      padding: 0;
      margin: 0;
      color: #575757;
      font-size: 14px;
    }
    table {
      width: 100%;
    }
    tfoot {
      font-weight: bold;
    }
      tfoot th {
        font-weight: bold;
        text-align: right;
      }
    th {
      font-weight: normal;
      text-align: left;
    }
    div.lo_body {
      padding: 0 0 50px;
      color: #666;
      background: #e5e5e5;
      font: normal 10px "Helvetica Neue", Helvetica, Arial, sans-serif;
      text-align: center;
    }
    p.lo_header {
      font: normal 10px "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    div.lo_content {
      border: solid 20px #fff;
      max-width: 540px;
      margin: 0 auto;
      color: #000;
      background: #fff;
      font: normal 18px/1.44 "Helvetica Neue", Helvetica, Arial, sans-serif;
      text-align: left;
    }
      a.lo_button {
        display: inline-block;
        padding: 0 8px;
        border: solid 1px #0d3459;
        border-top-color: #164c80;
        border-bottom-color: #041c32;
        border-radius: 5px;
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.5), 0 1px 0 rgba(0,0,0,0.75);
        color: #fff;
        background: #356797;
        text-shadow: 0 2px 0 rgba(0,0,0,0.75);
      }
      a.lo_button_large {
        padding: 10px 25px;
        font-size: 18px;
      }
      a.lo_add_link {
        font-size: 14px;
      }
      a.lo_visit_link {
        display: block;
        font-size: 12px;
        font-weight: bold;
        text-align: right;
      }
      div.lo_blockquote_wrapper {
        position: relative;
        padding: 25px;
        margin: 25px 0;
        color: #666;
        font-size: 14px;
      }
        div.lo_blockquote_wrapper:before,
        div.lo_blockquote_wrapper:after {
          position: absolute;
          color: #d2d2d2;
          font: normal 62px "Proxima Nova", Times, "Times New Roman", serif;
        }
        div.lo_blockquote_wrapper:before {
          top: 0;
          left: 0;
          content: "&quot;";
        }
        div.lo_blockquote_wrapper:after {
          right: 0;
          bottom: 0;
          content: "&quot;";
        }
        div.lo_blockquote_wrapper blockquote {
          margin: 0;
        }
      div.lo_call_to_action {
        padding: 23px 23px 10px;
        margin: 0 0 25px;
        text-align: center;
        color: #666;
        background: #eee;
        font-size: 12px;
      }
      img.lo_org_logo {
        width: 120px;
      }
      p.lo_note {
        font-size: 14px;
        line-height: 2.1;
        text-align: center;
      }
      p.lo_slogan {
        color: #666;
        font-weight: lighter;
        text-align: right;
      }
      span.lo_availability {
        font-size: 12px;
      }
      span.lo_hint {
        display: block;
        font-size: 14px;
      }
      h2.lo_reference_number {
        margin-bottom: .5em;
        color: #6e0206;
        font-weight: bold;
      }
      span.lo_order_number {
        color: #6e0206;
        font-weight: bold;
      }
      table.lo_content_header {
        width: 100%;
      }
    table.lo_fresh_sheet {
      border-collapse: collapse;
      margin: 0 0 25px;
    }
      table.lo_fresh_sheet tr:nth-child(odd) {
        background: #eee;
      }
      table.lo_fresh_sheet td,
      table.lo_fresh_sheet th {
        padding: 13px;
      }
      table.lo_fresh_sheet td {
        text-align: right;
      }
      table.lo_fresh_sheet td a {
        font-weight: bold;
      }
      table.lo_fresh_sheet img {
        width: 48px;
        margin: 0 13px 0 0;
        vertical-align: middle;
      }
    table.lo_order {
      border-collapse: collapse;
      font-size: 14px;
    }
      table.lo_order td,
      table.lo_order th {
        padding: 4px 10px;
      }
      table.lo_order th {
        font-weight: bold;
        line-height: 1.7;
      }
      table.lo_order tbody tr:nth-child(odd) {
        background: #f7f7f7;
      }
      th.lo_vendor {
        font-style: italic;
      }
      td.lo_currency {
        text-align: right;
      }
      th.lo_currency {
        text-align: right;
      }
    table.lo_steps {
      padding: 25px;
      margin: 25px 0;
      background: #eee;
    }
      table.lo_steps td {
        padding: 6px;
        vertical-align: top;
      }
      td.lo_call_to_action {
        text-align: center;
      }
      span.lo_step {
        display: block;
        width: 2em;
        -webkit-border-radius: 50%;
        -moz-border-radius: 50%;
        border-radius: 50%;
        color: #c7c7c7;
        background: #fff;
        font: bold 18px/2em "Helvetica Neue", Helvetica, Arial, sans-serif;
        text-align: center;
      }
    td.lo_placed_by {
      text-align: right;
    }
    div.lo_footer {
      font-size: 12px;
    }
      img.lo_logo {
        height: 45px;
        margin: 20px 0 0;
      }
  </style>
  <div class="lo_body">
    <p class="lo_header">&nbsp;</p>
    <div class="lo_content">
    <!-- Content Header -->
      <a href="http://'.$core->config['domain']['hostname'].'/app.php#!dashboard-home" class="lo_visit_link">Visit the Market &#x2799;</a>
      <table class="lo_content_header">
        <tr>
          <td>
            <a href="http://'.$core->config['domain']['hostname'].'"><img src="http://'.$core->config['domain']['hostname'].image('logo-large', $domain_id).'" alt="" class="lo_org_logo"></a>
          </td>
          <td>
            <p class="lo_slogan">'.$tagline.'</p>
          </td>
        </tr>
      </table>';
  }

  public static function footer($text)
  {
    global $core;
    return '<p class="lo_note"><em>'.$text.'</em></p>
          </div>

          <div class="lo_footer">
            <img src="http://'.$core->config['domain']['hostname'].image('logo-email').'" alt="Local Orbit Logo" class="lo_logo"><br>
            <strong>Powered by <a href="http://localorb.it/">Local Orbit</a></strong><br>
            <em class="lo_copyright">Copyright 2014. All Rights Reserved</em>
          </div>

          </div></body></html>';
  }

}