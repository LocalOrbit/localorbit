$(".select_buyer_id").empty().append("<option value=''>All Buyers</option><%= escape_javascript(render(:partial => '/shared/update_organizations', :collection => @organizations, :as => :organization)) %>")
$(".select_buyer_id").trigger("chosen:updated");
