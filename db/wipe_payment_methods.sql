delete from organization_payment_methods;


INSERT INTO organization_payment_methods (org_id,label,name_on_account,nbr1,nbr1_last_4,nbr2,nbr2_last_4)
SELECT otd.org_id,'Test Buyer Account' as label,'BLOCKWORK,LLC' as name_on_account,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr1,'7035' as nbr1_last_4,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr2,'0139' as nbr2_last_4 from organizations_to_domains otd inner join organizations o on otd.org_id=o.org_id where orgtype_id=3 and o.allow_sell=0;
 
 
INSERT INTO organization_payment_methods (org_id,label,name_on_account,nbr1,nbr1_last_4,nbr2,nbr2_last_4)
SELECT otd.org_id,'Test Seller Account' as label,'BLOCKWORK,LLC' as name_on_account,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr1,'7043' as nbr1_last_4,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr2,'0139' as nbr2_last_4 from organizations_to_domains otd inner join organizations o on otd.org_id=o.org_id where orgtype_id=3 and o.allow_sell=1;
 
 
INSERT INTO organization_payment_methods (org_id,label,name_on_account,nbr1,nbr1_last_4,nbr2,nbr2_last_4)
SELECT otd.org_id,'Test Market Account' as label,'BLOCKWORK,LLC' as name_on_account,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr1,'7027' as nbr1_last_4,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr2,'0139' as nbr2_last_4 from organizations_to_domains otd inner join organizations o on otd.org_id=o.org_id where orgtype_id=2;
 
INSERT INTO organization_payment_methods (org_id,label,name_on_account,nbr1,nbr1_last_4,nbr2,nbr2_last_4)
SELECT otd.org_id,'LO Account' as label,'BLOCKWORK,LLC' as name_on_account,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr1,'7019' as nbr1_last_4,'1YN98ZVB0yGlnv08Gi0_kZoKp8ByELGx0Mw8z1aDciU,' as nbr2,'0139' as nbr2_last_4 from organizations_to_domains otd inner join organizations o on otd.org_id=o.org_id where orgtype_id=1;


update product_prices set price=round(rand()*10)/100;