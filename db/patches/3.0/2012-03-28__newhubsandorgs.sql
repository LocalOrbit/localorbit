insert into domains (name, is_live) values ('Apple Ridge Farm' , 0);
select domain_id from domains where name='Apple Ridge Farm';
insert into organizations (orgtype_id, domain_id, name) values (2, 17, 'Apple Ridge Farm Market Manager Organization');

insert into domains (name, is_live) values ('Willowood' , 0);
select domain_id from domains where name='Willowood';
insert into organizations (orgtype_id, domain_id, name) values (2, 18, 'Willowood Market Manager Organization');

insert into domains (name, is_live) values ('Farm to Table' , 0);
select domain_id from domains where name='Farm to Table';
insert into organizations (orgtype_id, domain_id, name) values (2, 19, 'Farm to Table Market Manager Organization');

insert into domains (name, is_live) values ('Food Alliance Baltimore' , 0);
select domain_id from domains where name='Food Alliance Baltimore';
insert into organizations (orgtype_id, domain_id, name) values (2, 20, 'Farm Alliance Baltimore Market Manager Organization');