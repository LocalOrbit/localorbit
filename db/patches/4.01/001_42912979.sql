update organizations set profile = null where profile = 'Please enter your organization\'s story in the "Who" field.';
update organizations set product_how = null where product_how = '	
 
Please enter your products'' story in the "How" field.';

update products,organizations
set products.who = organizations.profile
where products.org_id = organizations.org_id and products.who = 'Please enter your organization\'s story in the "Who" field.';


update products,organizations
set products.how = organizations.product_how
where products.org_id = organizations.org_id and products.how = '	
 
Please enter your products\' story in the "How" field.';