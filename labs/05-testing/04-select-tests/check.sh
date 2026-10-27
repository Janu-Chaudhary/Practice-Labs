#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 04-select-tests  (looks at the runs recorded in work/.runs.log)"
ran() { [ -f .runs.log ] && grep -qxF "$1" .runs.log; }
check "you ran ONLY the 3 email tests (-k email)" 'ran "test_email_lowercased test_email_max_length test_email_requires_at"'
check "you ran ONLY test_password_too_short (file::test)" 'ran "test_password_too_short"'
check "you ran ONLY the password tests that are not about short (-k \"password and not short\")" 'ran "test_password_ok"'
check "you ran the whole suite at least once (6 tests)" 'ran "test_email_lowercased test_email_max_length test_email_requires_at test_name_stripped test_password_ok test_password_too_short"'
summary
