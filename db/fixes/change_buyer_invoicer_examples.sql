/* step one: change the buyer order payables to be to the market.*/

update payables set to_org_id=1434 where parent_obj_id in (select lo_oid from lo_order where domain_id=37) and payable_type_id=1 and invoice_id is null;

/* step 2: for all the payables where lo is supposed to pay the market their fee, 
change them so that they're the market paying LO the lo fee*/
update payables set payable_type_id=4,from_org_id=1434,to_org_id=1,amount = ((amount / 4) + 7)
where payable_type_id=3 and domain_id=37;

/* add payables from lo to the market for all the money collected via paypal*/
insert into payables (domain_id,payable_type_id,parent_obj_id,description,from_org_id,to_org_id,amount,creation_date)
values (37,2,7824,'LO-13-037-0007824',1,1434,(0.95 * 200.50),CURRENT_TIMESTAMP);

insert into payables (domain_id,payable_type_id,parent_obj_id,description,from_org_id,to_org_id,amount,creation_date)
values (37,2,7868,'LO-13-037-0007868',1,1434,(0.95 * 25),CURRENT_TIMESTAMP);

insert into payables (domain_id,payable_type_id,parent_obj_id,description,from_org_id,to_org_id,amount,creation_date)
values (37,2,8253,'LO-13-037-0008253',1,1434,(0.95 * 41.50),CURRENT_TIMESTAMP);

insert into payables (domain_id,payable_type_id,parent_obj_id,description,from_org_id,to_org_id,amount,creation_date)
values (37,2,8298,'LO-13-037-0008298',1,1434,(0.95 * 71),CURRENT_TIMESTAMP);

insert into payables (domain_id,payable_type_id,parent_obj_id,description,from_org_id,to_org_id,amount,creation_date)
values (37,2,8376,'LO-13-037-0008376',1,1434,(0.95 * 31),CURRENT_TIMESTAMP);