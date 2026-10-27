#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 10-twist-two-branches-05"
q() { sqlite3 shop.db "$1"; }
NEW=migrations/202610261030_create_reviews
check "on branch reviews" '[ "$(git branch --show-current)" = reviews ]'
check "$NEW.up.sql at reviews creates reviews" 'git show reviews:$NEW.up.sql | grep -qi "create table reviews"'
check "$NEW.down.sql at reviews drops reviews" 'git show reviews:$NEW.down.sql | grep -qi "drop table reviews"'
check "05_create_reviews.up.sql and .down.sql are gone" '! git cat-file -e reviews:migrations/05_create_reviews.up.sql 2>/dev/null && ! git cat-file -e reviews:migrations/05_create_reviews.down.sql 2>/dev/null && [ ! -e migrations/05_create_reviews.up.sql ] && [ ! -e migrations/05_create_reviews.down.sql ]'
check "main's 05_create_wishlist files are there, unchanged" 'git diff --quiet main reviews -- migrations/05_create_wishlist.up.sql migrations/05_create_wishlist.down.sql && git cat-file -e reviews:migrations/05_create_wishlist.up.sql'
check "main is merged into reviews; main unchanged" 'git merge-base --is-ancestor main reviews && [ "$(git rev-parse main)" = "$(cat .git/lab-main-tip)" ]'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
check "history: 05 (wishlist) Success" '[ "$(q "SELECT script FROM flyway_schema_history WHERE version='"'05'"' AND success=1")" = 05_create_wishlist.up.sql ]'
check "history: 202610261030 (reviews) Success" '[ "$(q "SELECT script FROM flyway_schema_history WHERE version='"'202610261030'"' AND success=1")" = 202610261030_create_reviews.up.sql ]'
check "tables wishlist and reviews exist; old data kept" 'q "SELECT 1 FROM wishlist LIMIT 1; SELECT 1 FROM reviews LIMIT 1" && [ "$(q "SELECT count(*) FROM users")" = 2 ]'
check "flyway validate passes" '"$LAB_DIR/../../bin/flyway" validate'
summary
