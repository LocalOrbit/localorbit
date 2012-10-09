-- create table for delivery fees

drop table if exists delivery_fees;
drop table if exists fee_calc_types;

create table fee_calc_types (
    `fee_calc_type_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `fee_calc_description` varchar(255) NOT NULL
);

create table delivery_fees (
    `devfee_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `dd_id` int(11) NOT NULL,
    `fee_type` varchar(255) NOT NULL,
    `fee_calc_type_id` int(11) NOT NULL,
    `amount` decimal(10, 2) NOT NULL,
    `minimum_order` decimal(10,2) NOT NULL
);


insert into fee_calc_types (fee_calc_description) values ('percentage');
insert into fee_calc_types (fee_calc_description) values ('dollar');