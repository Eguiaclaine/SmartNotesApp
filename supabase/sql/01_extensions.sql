-- =============================================================================
-- 01_extensions.sql
-- Enable required PostgreSQL extensions for DailyLog / notesApp
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
