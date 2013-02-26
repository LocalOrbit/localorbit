<?
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

function format_sql_value ($value) {
   if (is_null($value))
   {
      return "NULL";
   }
   if (!is_numeric($value) &&is_string($value))
   {
      return "'" . addslashes($value) . "'";
   }
   return $value;
}

if (count($argv) != 3) {
   echo "usage:\t\tphp -f " . $argv[0] . ' {old database name} {new database name}' . "\n";
   echo "example:\tphp -f " . $argv[0] . ' localorb_www_production localorb_www_testing'. "\n";
   exit;
}

$statement_formats = array(
   'insert' =>   'insert into phrases (pcat_id, label, tags, default_value, sort_order, edit_type, info_note) values (%2$d, %3$s, %4$s, %5$s, %6$d, %7$s, %8$s)',
   'update' =>   'update phrases set pcat_id = %2$d, label = %3$s, tags = %4$s, default_value = %5$s, sort_order = %6$d, edit_type = %7$s, info_note  = %8$s where phrase_id = %1$d',
   'delete' =>   'delete from phrases where phrase_id = %9$d');

$statements = array_fill_keys(array_keys($statement_formats), array());

$phrases = core_db::query(vsprintf('select *
from (select *,
CASE WHEN c.`new.default_value` is not null and c.`old.default_value` is null THEN \'insert\'
         WHEN c.`new.default_value` is null and c.`old.default_value` is not null THEN \'delete\'
         WHEN c.`new.default_value` != c.`old.default_value` THEN \'update\'
      ELSE null END AS `change` from (SELECT
`%3$s`.`phrases`.`phrase_id` as `new.phrase_id`,
`%3$s`.`phrases`.`pcat_id` as     `new.pcat_id`,
`%3$s`.`phrases`.`label`as        `new.label`,
`%3$s`.`phrases`.`tags`as        `new.tags`,
`%3$s`.`phrases`.`default_value` as`new.default_value`,
`%3$s`.`phrases`.`sort_order`as  `new.sort_order`,
`%3$s`.`phrases`.`edit_type` as   `new.edit_type`,
`%3$s`.`phrases`.`info_note` as   `new.info_note`,
`%2$s`.`phrases`.`phrase_id` as `old.phrase_id`,
`%2$s`.`phrases`.`pcat_id` as     `old.pcat_id`,
`%2$s`.`phrases`.`label`as        `old.label`,
`%2$s`.`phrases`.`tags`as        `old.tags`,
`%2$s`.`phrases`.`default_value` as`old.default_value`,
`%2$s`.`phrases`.`sort_order`as  `old.sort_order`,
`%2$s`.`phrases`.`edit_type` as   `old.edit_type`,
`%2$s`.`phrases`.`info_note` as   `old.info_note`
FROM `%3$s`.`phrases`
left join %2$s.phrases on %3$s.phrases.phrase_id = %2$s.phrases.phrase_id
union
SELECT
`%3$s`.`phrases`.`phrase_id` as `new.phrase_id`,
`%3$s`.`phrases`.`pcat_id` as     `new.pcat_id`,
`%3$s`.`phrases`.`label`as        `new.label`,
`%3$s`.`phrases`.`tags`as        `new.tags`,
`%3$s`.`phrases`.`default_value` as`new.default_value`,
`%3$s`.`phrases`.`sort_order`as  `new.sort_order`,
`%3$s`.`phrases`.`edit_type` as   `new.edit_type`,
`%3$s`.`phrases`.`info_note` as   `new.info_note`,
`%2$s`.`phrases`.`phrase_id` as `old.phrase_id`,
`%2$s`.`phrases`.`pcat_id` as     `old.pcat_id`,
`%2$s`.`phrases`.`label`as        `old.label`,
`%2$s`.`phrases`.`tags`as        `old.tags`,
`%2$s`.`phrases`.`default_value` as`old.default_value`,
`%2$s`.`phrases`.`sort_order`as  `old.sort_order`,
`%2$s`.`phrases`.`edit_type` as   `old.edit_type`,
`%2$s`.`phrases`.`info_note` as   `old.info_note`
FROM %2$s.phrases
left join `%3$s`.`phrases`on %2$s.phrases.phrase_id = %3$s.phrases.phrase_id) as c) as cc
where `change` is not null', $argv));

while($phrase = core_db::fetch_assoc($phrases)) {
   $change = $phrase['change'];
   $phrase = array_map('format_sql_value', $phrase);
   $statements[$change][] = vsprintf($statement_formats[$change], array_values($phrase));
}

foreach ($statements as $set) {
   if($not_first_set)
   {
      echo "\n";
   }
   foreach ($set as $sql)
   {
      echo $sql . ';' . "\n";
   }
   $not_first_set = true;
}
?>