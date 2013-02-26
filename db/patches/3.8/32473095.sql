INSERT INTO `phrases`
(
`pcat_id`,
`label`,
`default_value`,
`edit_type`)
VALUES
(
3,
'email:suspend_mm',
'The organization \'{org_name}\' has been suspended due to an overdue balance of ${amount_overdue}.<br><br>If you have any questions please respond to this email.<br>',
'text'
);