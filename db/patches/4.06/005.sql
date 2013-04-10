INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.06', '005', '47560257');

drop table  if exists payments_ach_history;

create table payments_ach_history (
    `pah_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `payment_id` int(11) NOT NULL,
    `event_id` varchar(50),
    `response_code` varchar(5) NOT NULL,
    `action_detail` varchar(5) NOT NULL,
    `effective_date` timestamp default '0000-00-00 00:00:00',
    `action_date` timestamp default '0000-00-00 00:00:00',
    `recorded_on` timestamp default CURRENT_TIMESTAMP
);
