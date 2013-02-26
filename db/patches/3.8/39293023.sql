alter table domains add column payable_org_id int(10);

update domains set domains.payable_org_id = (
    select organizations_to_domains.org_id from organizations_to_domains 
    left join organizations on organizations_to_domains.org_id = organizations.org_id 
    where orgtype_id = 2 and is_home = 1 and organizations_to_domains.domain_id = domains.domain_id limit 1);

select domain_id, payable_org_id from domains;

alter table domains add column seller_payment_managed_by enum('fully_managed','self_managed');
update domains set seller_payment_managed_by='fully_managed';