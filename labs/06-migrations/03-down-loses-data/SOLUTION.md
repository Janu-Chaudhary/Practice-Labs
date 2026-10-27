# Solution - 03 down loses data

```bash
cd work
flyway info                                         # 01 Success, 02 Success
sqlite3 -header -column shop.db "SELECT * FROM users;"   # id user_name  (no bio)
sqlite3 shop.db < migrations/02_drop_bio.down.sql   # runs: ALTER TABLE users ADD COLUMN bio text;
sqlite3 -header -column shop.db "SELECT * FROM users;"   # bio is empty (NULL) for Asha and Ravi
sqlite3 shop.db "DELETE FROM flyway_schema_history WHERE version = '02';"   # history now matches the schema
flyway info                                         # 02 Pending
```

**Why NULL?** The down file is *new SQL* that runs after the drop committed. `ADD COLUMN bio text`
makes an empty column with the right name and type. The old values were deleted by the up migration and
are not stored anywhere (not in the history table either - it only stores version, file name, checksum).
Only a **backup restore** gets them back. ROLLBACK can't help: the drop was committed long ago.

Why delete the history row? The history table must describe what is really in the database.
After the down, 02 is no longer applied; if the row stayed, Flyway would think bio is gone.
Tools with built-in down support (`migrate down`, Flyway Teams `undo`) do both steps in one go.

**Common wrong attempts**
- `sqlite3 shop.db migrations/02_drop_bio.down.sql` (no `<`) - sqlite treats the file name as SQL -> syntax error.
- `DELETE ... WHERE version = 02` (no quotes) - SQLite compares text '02' with number 2 -> deletes nothing.
- Running `flyway migrate` after deleting the row - 02 runs again and drops bio again.
- Using `flyway repair` - repair does not remove successful rows; it only fixes checksums / failed rows.
