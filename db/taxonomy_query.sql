-- The current product migration script requires that category_id be manually added into the template CSV.
-- This is a query to grab the categories with a heirarchical list to help the human filling out the template decide what they want to put in the column
-- Limiting to 3 levels of depth (including "All", eg "All > Beverages > Beer") to make manual categorization easier.

WITH RECURSIVE category_taxonomy
AS
(
    SELECT
        categories.name,
        id,
        parent_id,
        categories.name::text AS taxonomy,
        1 as height
    FROM categories WHERE parent_id IS NULL
    UNION
    SELECT
        child.name,
        child.id,
        child.parent_id,
        category_taxonomy.taxonomy || ' > ' || child.name::text AS taxonomy,
        category_taxonomy.height + 1 as height
    FROM
        category_taxonomy
        JOIN categories child ON child.parent_id = category_taxonomy.id
)
SELECT
  name,
  id,
  taxonomy
FROM
  category_taxonomy
WHERE
  height = 3
ORDER BY taxonomy;