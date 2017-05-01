$("#supplier_products").empty()
$("#supplier_products").append("<option>Select Parent Product</option>")
$("#supplier_products").append("<%= escape_javascript(render(:partial => @supplier_products)) %>")
$('#supplier_products').trigger("chosen:updated");