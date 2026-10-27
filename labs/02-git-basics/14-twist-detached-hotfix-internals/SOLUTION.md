# Solution 14

## Part A
```bash
git switch --detach v1.0          # or: git checkout v1.0   -> "You are in 'detached HEAD' state"
git status                        # HEAD detached at v1.0
cat config.py                     # RETRIES = 0
code config.py                    # make it RETRIES = 3, save
#   no-editor equivalent:  echo "RETRIES = 3" > config.py
git commit -am "Fix retries for 1.0"   # commit on top of v1.0 (still detached)
git switch -c v1-hotfix           # create a branch HERE and switch to it: the commit is now saved
git log --oneline --graph --all --decorate
git switch main
```

Why:
- `git switch --detach v1.0` moves HEAD straight onto a commit. Plain `git switch v1.0` refuses
  ("a branch is expected"), because switch only goes to branches unless you say `--detach`.
  `git checkout v1.0` detaches without asking.
- In detached HEAD you can commit normally; the new commit's parent is v1.0's commit. But no branch
  moves forward with it, so it's only reachable through HEAD.
- `git switch -c v1-hotfix` creates a branch at the current commit (HEAD) and attaches HEAD to it.
  Now the commit has a name and is safe. (`git branch v1-hotfix` works too, it just doesn't switch.)

## Part B
```bash
git cat-file -p v1-hotfix         # first line: tree <HASH>   <- line 1 of answers
git rev-parse v1-hotfix^{tree}    # same hash, shorter way
git cat-file -t v1.0              # tag     <- annotated tags are their own objects (line 2)
git cat-file -t main              # commit  (compare: a branch is just a name for a commit)
git cat-file -p main^{tree}       # one line per file: mode, type, hash, name
#   100644 blob 2f1a...  README.md
#   100644 blob 7c3e...  app.py
#   100644 blob 9d4b...  banner.txt
#   ...
#   100644 blob 9d4b...  motd.txt      <- same hash as banner.txt (line 3)
echo "$(git rev-parse v1-hotfix^{tree})" > answers.txt
echo "tag" >> answers.txt
echo "motd.txt" >> answers.txt
cat answers.txt
```

Why:
- A commit object stores one `tree` line (the snapshot of the whole project), parent(s), author and
  message. The tree lists each file's blob hash and name.
- Objects are content-addressed: the hash comes from the content. banner.txt and motd.txt contain the
  same bytes, so they are ONE blob, stored once. The file names live in the tree, not in the blob.
- `v1.0` was made with `git tag -a`, so it is a tag object (type `tag`) pointing at a commit.
  A lightweight tag would just be a name, and `cat-file -t` would print `commit`.

## Common wrong attempts
- `git switch main` straight after committing in detached HEAD: git warns
  "you are leaving 1 commit behind, not connected to any of your branches" and prints the hash.
  Fix: `git branch v1-hotfix <that hash>` (or find it with `git reflog`).
- Editing config.py on main and committing: main changes, and the hotfix contains v2 code.
- `git switch -c v1-hotfix` BEFORE `git switch --detach v1.0`: the branch starts at main, so it has
  4 + 1 commits. Make the branch from v1.0: `git switch -c v1-hotfix v1.0` is a valid shortcut
  that skips detached HEAD entirely.
- Writing the commit's hash on line 1 instead of the tree's hash.
- Writing `commit` on line 2: that's what `cat-file -t v1.0^{commit}` gives, not `v1.0` itself.
