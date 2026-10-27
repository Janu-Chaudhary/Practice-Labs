#!/usr/bin/env bash
# Helpers shared by the 06-migrations labs. Sourced AFTER lib/common.sh.
FLYWAY="$LAB_DIR/../../bin/flyway"
BIN_DIR="$(cd "$LAB_DIR/../../bin" && pwd)"

# toml_course: flyway.toml for the course naming  NN_name.up.sql  (down files are ignored by Flyway)
toml_course() {
cat > flyway.toml <<'T'
# Flyway settings for this folder. The flyway wrapper runs Flyway here, so paths are relative to it.
[environments.default]
url = "jdbc:sqlite:shop.db"          # the database: an SQLite file next to this config

[flyway]
environment = "default"
locations = ["filesystem:migrations"] # where the migration files live
# Course naming: 03_add_currency.up.sql  ->  version 03, description "add currency"
sqlMigrationPrefix = ""               # no "V" in front
sqlMigrationSeparator = "_"           # first "_" splits version from description
sqlMigrationSuffixes = [".up.sql"]    # only .up.sql files are migrations (Flyway never runs .down.sql)
validateMigrationNaming = true        # a badly named .up.sql is an error, not silently skipped
T
}

# toml_default: flyway.toml with Flyway's own default naming  V3__add_email.sql
toml_default() {
cat > flyway.toml <<'T'
# Flyway settings for this folder. The flyway wrapper runs Flyway here, so paths are relative to it.
[environments.default]
url = "jdbc:sqlite:shop.db"          # the database: an SQLite file next to this config

[flyway]
environment = "default"
locations = ["filesystem:migrations"] # where the migration files live
# Default Flyway naming: V<version>__<description>.sql   (capital V, TWO underscores)
validateMigrationNaming = true        # a badly named .sql is an error, not silently skipped
T
}

# fw <args>: run flyway quietly during setup; show output only if it fails
fw() {
  local out; out="$("$FLYWAY" "$@" 2>&1)" || { echo "$out"; echo "${R}setup: flyway $* failed${N}"; exit 1; }
}

# path_tip: one-time PATH reminder for the student
path_tip() {
  if ! command -v flyway >/dev/null 2>&1; then
    echo "${Y}First, once per terminal:${N}  export PATH=\"$BIN_DIR:\$PATH\"   (gives you the ${B}flyway${N} command)"
  fi
}
