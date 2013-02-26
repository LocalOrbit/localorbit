INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('010', '');

INSERT INTO `phrases`
(
`pcat_id`,
`label`,
`default_value`,
`edit_type`)
VALUES
(
3,
'error:newsletter:must_choose_group',
'You haven\'t chosen any recipients for your newsletter.  Please select Buyers, Sellers or both groups.',
'text'
);