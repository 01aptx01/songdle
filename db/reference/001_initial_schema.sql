-- Songdle PostgreSQL 15+ DDL reference draft.
-- Convert to versioned migration and validate in isolated PostgreSQL before production use.
-- No commercial music content is bundled.

CREATE TABLE songs (
  id uuid PRIMARY KEY,
  title text NOT NULL CHECK (length(trim(title)) > 0),
  genre text NOT NULL DEFAULT 'TPOP',
  release_year smallint CHECK (release_year BETWEEN 1900 AND 2100),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE artists (
  id uuid PRIMARY KEY,
  name text NOT NULL CHECK (length(trim(name)) > 0),
  search_name text NOT NULL CHECK (length(trim(search_name)) > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE song_artists (
  song_id uuid NOT NULL REFERENCES songs(id) ON DELETE RESTRICT,
  artist_id uuid NOT NULL REFERENCES artists(id) ON DELETE RESTRICT,
  credit_role text NOT NULL CHECK (credit_role IN ('primary', 'featured')),
  credit_order integer NOT NULL DEFAULT 0 CHECK (credit_order >= 0),
  is_accepted_answer boolean NOT NULL DEFAULT false,
  PRIMARY KEY (song_id, artist_id)
);

CREATE TABLE audio_clips (
  id uuid PRIMARY KEY,
  song_id uuid NOT NULL REFERENCES songs(id) ON DELETE RESTRICT,
  storage_key text NOT NULL UNIQUE CHECK (length(trim(storage_key)) > 0),
  duration_ms integer NOT NULL CHECK (duration_ms = 10000),
  rights_status text NOT NULL CHECK (rights_status IN ('PENDING', 'APPROVED', 'REJECTED', 'EXPIRED')),
  license_reference text,
  is_active boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (id, song_id),
  CHECK (NOT (is_active AND rights_status <> 'APPROVED')),
  CHECK (rights_status <> 'APPROVED' OR NULLIF(trim(license_reference), '') IS NOT NULL)
);

CREATE UNIQUE INDEX one_active_clip_per_song ON audio_clips(song_id) WHERE is_active;

CREATE TABLE game_sessions (
  id uuid PRIMARY KEY,
  song_id uuid NOT NULL REFERENCES songs(id) ON DELETE RESTRICT,
  audio_clip_id uuid NOT NULL,
  mode text NOT NULL CHECK (mode IN ('SONG','ARTIST')),
  status text NOT NULL DEFAULT 'PLAYING' CHECK (status IN ('PLAYING','WON','LOST')),
  attempts_used smallint NOT NULL DEFAULT 0 CHECK (attempts_used BETWEEN 0 AND 5),
  score smallint NOT NULL DEFAULT 0 CHECK (score BETWEEN 0 AND 100),
  guest_token_hash text NOT NULL CHECK (length(guest_token_hash) > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz,
  FOREIGN KEY (audio_clip_id, song_id) REFERENCES audio_clips(id, song_id) ON DELETE RESTRICT,
  CHECK (
    (status='PLAYING' AND score=0 AND finished_at IS NULL) OR
    (status='WON' AND attempts_used BETWEEN 1 AND 5 AND score=120-20*attempts_used AND finished_at IS NOT NULL) OR
    (status='LOST' AND attempts_used=5 AND score=0 AND finished_at IS NOT NULL)
  )
);

CREATE TABLE guesses (
  id uuid PRIMARY KEY,
  session_id uuid NOT NULL REFERENCES game_sessions(id) ON DELETE RESTRICT,
  guessed_song_id uuid REFERENCES songs(id) ON DELETE RESTRICT,
  guessed_artist_id uuid REFERENCES artists(id) ON DELETE RESTRICT,
  attempt_number smallint NOT NULL CHECK (attempt_number BETWEEN 1 AND 5),
  is_correct boolean NOT NULL,
  idempotency_key uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK ( (guessed_song_id IS NOT NULL AND guessed_artist_id IS NULL)
       OR (guessed_song_id IS NULL AND guessed_artist_id IS NOT NULL) ),
  UNIQUE (session_id, attempt_number),
  UNIQUE (session_id, idempotency_key),
  UNIQUE (session_id, guessed_song_id),
  UNIQUE (session_id, guessed_artist_id)
);

CREATE INDEX idx_song_artists_song_accepted ON song_artists(song_id, is_accepted_answer);
CREATE INDEX idx_song_artists_artist ON song_artists(artist_id);
CREATE INDEX idx_game_sessions_guest_created ON game_sessions(guest_token_hash, created_at DESC);
CREATE INDEX idx_game_sessions_status_created ON game_sessions(status, created_at);
CREATE INDEX idx_guesses_session_created ON guesses(session_id, created_at);
CREATE INDEX idx_artists_search_name ON artists(search_name);
CREATE INDEX idx_songs_title ON songs(title);

-- Integrity notes handled by application service:
-- * artist/song candidate type matches session mode
-- * accepted artist maps to active song and artist, no stale candidate
-- * pick only active eligible song+approved active clip
-- * atomic row lock/update and idempotency payload matching
-- * prevent target leakage to clients
