-- ============================================================================
-- DATA1500 - Oppgavesett 1.5: Databasemodellering og implementasjon
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller



-- Sett inn testdata



-- Eventuelt: Opprett indekser for ytelse



-- Vis at initialisering er fullført
SELECT 'Database initialisert!' as status;

```sql
-- Drop i riktig rekkefølge
DROP TABLE IF EXISTS forum_post CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS group_classroom_access CASCADE;
DROP TABLE IF EXISTS group_member CASCADE;
DROP TABLE IF EXISTS app_group CASCADE;
DROP TABLE IF EXISTS classroom CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;

-- Brukere
CREATE TABLE app_user (
  user_id        SERIAL PRIMARY KEY,
  username       VARCHAR(50) NOT NULL UNIQUE,
  password_hash  TEXT NOT NULL,
  role           VARCHAR(20) NOT NULL CHECK (role IN ('student', 'teacher')),
  full_name      TEXT NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Klasserom
CREATE TABLE classroom (
  classroom_id   SERIAL PRIMARY KEY,
  code           VARCHAR(20) NOT NULL UNIQUE,
  name           TEXT NOT NULL,
  teacher_id     INT NOT NULL REFERENCES app_user(user_id) ON DELETE RESTRICT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Grupper
CREATE TABLE app_group (
  group_id     SERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Medlemskap
CREATE TABLE group_member (
  group_id   INT NOT NULL REFERENCES app_group(group_id) ON DELETE CASCADE,
  user_id    INT NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
  joined_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (group_id, user_id)
);

-- Tilgang gruppe -> klasserom
CREATE TABLE group_classroom_access (
  group_id      INT NOT NULL REFERENCES app_group(group_id) ON DELETE CASCADE,
  classroom_id  INT NOT NULL REFERENCES classroom(classroom_id) ON DELETE CASCADE,
  granted_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (group_id, classroom_id)
);

-- Beskjeder
CREATE TABLE message (
  message_id    SERIAL PRIMARY KEY,
  classroom_id  INT NOT NULL REFERENCES classroom(classroom_id) ON DELETE CASCADE,
  sender_id     INT NOT NULL REFERENCES app_user(user_id) ON DELETE RESTRICT,
  sent_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  title         TEXT NOT NULL,
  content       TEXT NOT NULL
);

-- Foruminnlegg (hierarki)
CREATE TABLE forum_post (
  post_id        SERIAL PRIMARY KEY,
  classroom_id   INT NOT NULL REFERENCES classroom(classroom_id) ON DELETE CASCADE,
  sender_id      INT NOT NULL REFERENCES app_user(user_id) ON DELETE RESTRICT,
  parent_post_id INT NULL REFERENCES forum_post(post_id) ON DELETE CASCADE,
  posted_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  title          TEXT NOT NULL,
  content        TEXT NOT NULL
);

-- -------------------
-- MOCK DATA
-- -------------------

INSERT INTO app_user (username, password_hash, role, full_name) VALUES
('teacher_anna', 'hash1', 'teacher', 'Anna Lærer'),
('teacher_ola',  'hash2', 'teacher', 'Ola Lærer'),
('stud_jens',  'hash3', 'student', 'Jens Student'),
('stud_mina',  'hash4', 'student', 'Mina Student'),
('stud_sara',  'hash5', 'student', 'Sara Student'),
('stud_emil',  'hash6', 'student', 'Emil Student');

INSERT INTO classroom (code, name, teacher_id) VALUES
('DB-101', 'Databaser Grunnkurs', 1),
('WEB-202', 'Webutvikling', 2);

INSERT INTO app_group (name) VALUES
('Gruppe A'),
('Gruppe B');

INSERT INTO group_member (group_id, user_id) VALUES
(1, 3), (1, 4), (1, 5),
(2, 6);

INSERT INTO group_classroom_access (group_id, classroom_id) VALUES
(1, 1), (1, 2),
(2, 1);

INSERT INTO message (classroom_id, sender_id, title, content) VALUES
(1, 1, 'Velkommen', 'Velkommen til kurset!'),
(1, 1, 'Ukeplan', 'Her er ukeplanen.'),
(1, 1, 'Oblig 1', 'Oblig 1 er publisert.');

INSERT INTO forum_post (classroom_id, sender_id, title, content, parent_post_id)
VALUES
(1, 4, 'Spørsmål om PK/FK', 'Hva er forskjellen på PK og FK?', NULL);

INSERT INTO forum_post (classroom_id, sender_id, title, content, parent_post_id)
VALUES
(1, 1, 'Svar', 'PK identifiserer rad, FK peker til annen tabell.', 1);
```