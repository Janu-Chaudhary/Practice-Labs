# Practice pack spec (shared by every topic agent)

## Who it's for
A 3rd-year CS student with a quiz in 2 days. They understand the concepts (MCQs go fine) but have
almost never typed git/docker/shell/flyway commands themselves. In the last two quizzes they lost
terminal tasks on tiny things: not knowing why `docker build -t x:1 .` needs the `.`, never having used
grep/pipes/redirects, not knowing what Flyway is or how to rename a migration to a timestamp version.
Goal: enough hands-on reps that they can handle NEW, unseen terminal scenarios, not only the past ones.
They know basic cd/ls/cat; teach anything beyond that. Simple English, short sentences.

Source material (read what is relevant to your topic):
- Quiz papers with answers: /tmp/claude-1000/-home-janu-chaudhary-Desktop-csp/ec5d5357-3bd1-434e-97de-b7eb301546a5/scratchpad/txt/quiz-1a.txt and quiz-2a.txt
- Lecture slide text: /tmp/claude-1000/-home-janu-chaudhary-Desktop-csp/ec5d5357-3bd1-434e-97de-b7eb301546a5/scratchpad/c/*.txt
  (T0L1 version control, T1L1 runtime/containers/secrets, T2L1 git internals, T2L2 testing+CI,
  T3L1 containers, T3L2 database migrations)
Match the professor's vocabulary and scenario style (the four locations, named volumes, history table, etc).

In the quiz, files are edited in a browser file panel and commands typed in a terminal. Locally the
student edits files with VS Code (`code file`) or nano. Checks are on final state (branch tips, commit
counts, file contents), so extra commits / wrong branch / wrong order fail.

## Layout (root = /home/janu-chaudhary/Desktop/csp/practice)
```
labs/lib/common.sh            shared helpers (already exists - read it, do not edit)
labs/bin/                     shared wrappers (only the migrations agent adds `flyway` here)
labs/NN-topic/MM-short-name/  one exercise
    TASK.md      situation + task + "Stop" rules + "What will be checked", worded like the quiz
    setup.sh     #!/usr/bin/env bash ; source "$(dirname "$0")/../../lib/common.sh" ; fresh_work ; ... ; banner "..."
    check.sh     source common.sh ; check "desc" '<shell test run inside work/>' ... ; summary
    SOLUTION.md  exact commands, each with a one-line why, plus the common wrong attempts and what they cause
_build/sections/NN-topic.html  your HTML guide fragment (format below)
```
- setup.sh must be idempotent: re-running resets everything (rm work, and for docker labs remove the
  containers/images/volumes the lab uses). Use `git_repo` for repos (fixed identity, branch main).
  For a "remote", create a bare repo inside work (e.g. work/remote.git) and clone/add it as origin.
- Use the helpers: fresh_work, git_repo, commit_file, check, hint, summary, banner, need_docker.
- check.sh must pass from the exercise folder (`./check.sh`) and from inside work (`../check.sh`); common.sh
  handles that as long as checks only use paths relative to work.
- chmod +x all .sh files. No interactive prompts in setup/check.
- When the student's natural command would open an editor (merge commit), say so in TASK.md hints.
- Ladder per topic: 3-4 **Drill** (one or two commands, warm-up), 3-4 **Quiz-style** (multi-step, like the
  real papers; recreate the relevant past quiz tasks faithfully), 1-2 **Twist** (an unseen variation that
  needs the same skills combined differently). Name folders e.g. `01-grep-basics`, `05-quiz-orders-500`.

## VERIFY EVERYTHING (mandatory)
For every exercise: run setup.sh -> run check.sh (must FAIL on the untouched state) -> apply SOLUTION.md
commands exactly -> check.sh must PASS -> run setup.sh again (must reset cleanly). Fix until true.
Afterwards leave each lab in its fresh (setup-run or never-run) state and remove any work/ dirs, and for
docker remove containers/volumes you created. Note: `grep` on this machine is ugrep 7.8 (mostly GNU
compatible); if behaviour differs from GNU grep, note it in the guide. Do not touch other topics' folders.

## HTML fragment format (_build/sections/NN-topic.html)
A fragment only: no <html>, <head>, <style>, <script>. Escape < > & inside code. Every id is prefixed
with your topic id. Use ONLY these components (the shell page styles them):

```html
<section class="topic" id="TOPICID" data-title="Short nav title">
  <header class="topic-head">
    <span class="tag">Topic N</span>
    <h2>Full title</h2>
    <p class="lede">One sentence: what you'll be able to do.</p>
  </header>

  <div class="model"><h3>Mental model</h3><p>3-5 lines. The picture to keep in your head.</p></div>

  <h3 class="sub" id="TOPICID-grep">grep: keep only matching lines</h3>   <!-- subsections appear in the sidebar -->
  <p>Short explanation.</p>

  <!-- break a command into parts; each span gets a numbered badge matching the list -->
  <div class="anatomy">
    <code><span>docker build</span> <span>-t counter:1.0</span> <span>.</span></code>
    <ol><li>the command</li><li>-t = tag: name:version for the image</li><li>. = build context: this folder</li></ol>
  </div>

  <table class="cmd"><thead><tr><th>Command</th><th>What it does</th></tr></thead>
    <tbody><tr><td><code>grep -i "x" f</code></td><td>ignore case</td></tr></tbody></table>

  <pre class="term"><span class="p">$</span> grep "status=500" logs/access.log
<span class="c"># comment lines look like this</span>
2026-09-28T09:03:29 service=orders ...   (plain text = output)</pre>

  <div class="callout trap"><strong>Trap</strong><p>...</p></div>
  <div class="callout tip"><strong>Tip</strong><p>...</p></div>
  <div class="callout why"><strong>Why</strong><p>...</p></div>

  <div class="err"><pre>fatal: not a git repository</pre><p><b>Means:</b> ...</p><p><b>Fix:</b> ...</p></div>

  <details class="scenario"><summary><span class="lvl quiz">Quiz-style</span> Title</summary>
    <div class="body"><p>Situation + task.</p>
      <details class="answer"><summary>Show answer</summary><pre class="term">...</pre><p>why</p></details>
    </div></details>
  <!-- lvl classes: drill | quiz | twist -->

  <div class="labs"><h3>Practice labs</h3><ul>
    <li><label><input type="checkbox" data-id="TOPICID-01"> <code>labs/01-shell/01-grep-basics</code>
      <span>One-line description</span> <span class="lvl drill">Drill</span></label></li>
  </ul></div>

  <div class="cheat"><h3>Cheat sheet</h3><ul><li><code>cmd</code> what it does</li></ul></div>
</section>
```
Section order: header, mental model, subsections (each: explanation, anatomy/command table, terminal
example, traps, common errors), 4-8 worked scenarios (mix of levels, include unseen variations, answers
hidden), practice-labs list (every lab you built, in order), cheat sheet (the 10-20 must-know lines).
Be thorough but tight: every flag the quiz could plausibly need, explained by *why*, not just *what*.
