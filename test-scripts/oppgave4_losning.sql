-- Oppgave 1
SELECT message_id, classroom_id, sender_id, sent_at, title, content
FROM message
WHERE classroom_id = 1
ORDER BY sent_at DESC
LIMIT 3;

-- Oppgave 2
WITH RECURSIVE diskusjonstraad AS (
  SELECT p.post_id, p.parent_post_id, p.classroom_id, p.sender_id, p.posted_at, p.title, p.content, 0 AS depth
  FROM forum_post p
  WHERE p.parent_post_id IS NULL AND p.sender_id = 4
  UNION ALL
  SELECT c.post_id, c.parent_post_id, c.classroom_id, c.sender_id, c.posted_at, c.title, c.content, dt.depth + 1
  FROM forum_post c
  JOIN diskusjonstraad dt ON c.parent_post_id = dt.post_id
)
SELECT *
FROM diskusjonstraad
ORDER BY depth, posted_at;

-- Oppgave 3
SELECT u.user_id, u.full_name, u.username
FROM group_member gm
JOIN app_user u ON u.user_id = gm.user_id
WHERE gm.group_id = 1 AND u.role = 'student'
ORDER BY u.full_name;

-- Oppgave 4
SELECT COUNT(*) AS antall_grupper
FROM app_group;
