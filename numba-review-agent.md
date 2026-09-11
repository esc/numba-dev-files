# Instructions for agents reviewing Numba and llvmlite pull-requests

Applies to `numba/numba` and `numba/llvmlite`. Local checkouts: `~/numba`
and `~/llvmlite`, which must always remain on `main` as base reference.

## Naming

- `PROJECT` = lowercase repository name: `numba` or `llvmlite`.
- `PR` = the pull-request number.
- Every artifact of a review uses the identifier `pr-review-PROJECT-PR`
  (e.g. `pr-review-numba-10827`): the review directory, the git worktree
  branch, the conda environment, and the final markdown file.

## Environment

- Use `conda` (base installation at `~/miniconda3`) for environments and
  dependencies. Never create environments with `pip` or `venv`.
- `pip` is used exactly once: for the editable build of the project
  itself. All dependencies come from conda.
- A reference environment `numba314` (Python 3.14) exists. Clone it; do
  not create environments from scratch:

  ```bash
  conda create -y -n pr-review-PROJECT-PR --clone numba314
  ```

  Use Python 3.14 unless the PR gives a reason not to.
- For dependency inspiration see
  https://github.com/esc/numba-dev-files/blob/master/Makefile
- Run all Python commands through `conda run`, which executes the
  environment's activation scripts. The compiler toolchain packages
  (gcc/g++) rely on activation variables being set, so calling the
  environment's interpreter directly does not work:

  ```bash
  conda run -n pr-review-PROJECT-PR --no-capture-output python ...
  ```

  Use `--no-capture-output` to keep output streaming; without it,
  `conda run` buffers output.

## Isolation (multiple agents share this machine)

- All review artifacts live in `~/reviews/pr-review-PROJECT-PR/`. Do not
  write outside that directory.
- Never build or modify `~/numba` or `~/llvmlite` directly; use a git
  worktree:

  ```bash
  mkdir -p ~/reviews/pr-review-PROJECT-PR
  git -C ~/PROJECT fetch https://github.com/numba/PROJECT.git pull/PR/head
  git -C ~/PROJECT worktree add ~/reviews/pr-review-PROJECT-PR/worktree \
      -b pr-review-PROJECT-PR FETCH_HEAD
  ```

- If a remote uses SSH, reconfigure it to read-only HTTPS before fetching.
- For A/B comparison against `main`, add a second worktree at
  `~/reviews/pr-review-PROJECT-PR/worktree-base` (detached at the merge
  base) and optionally a conda environment named `pr-review-PROJECT-PR-base`.
- Do not remove anything when finished. Leave all files, logs and
  environments in place for audit.

## GitHub access (read-only)

- `gh` is installed and authenticates via the `GH_TOKEN` environment
  variable — a fine-grained PAT verified read-only on numba/numba and
  numba/llvmlite. Use `git` for code and `gh api` for metadata:

  ```bash
  gh api repos/numba/PROJECT/pulls/PR                # base/head sha, mergeable
  gh api repos/numba/PROJECT/commits/SHA/check-runs  # CI status
  gh api repos/numba/PROJECT/issues/PR/comments      # discussion
  gh api repos/numba/PROJECT/pulls/PR/reviews        # existing reviews
  gh api repos/numba/PROJECT/pulls/PR/comments       # existing inline comments
  ```

- Read-only is enforced by the credential itself: write attempts fail
  with HTTP 403. Do not try to work around this (no other tokens, no SSH
  keys, no credential helpers).
- Check existing human reviews first; do not repeat findings already
  raised unless you disagree or can add evidence.
- Do not post comments or reviews to GitHub unless the task explicitly
  instructs it. The default deliverable is the local markdown file only.

## Reviewing

- Review the PR head commit. Compute the diff against the merge base:

  ```bash
  cd ~/reviews/pr-review-PROJECT-PR/worktree
  git merge-base origin/main HEAD
  git diff <merge-base>..HEAD
  ```

- Build in the review environment:

  ```bash
  conda run -n pr-review-PROJECT-PR --no-capture-output \
      python -m pip install -vv -e .
  ```

- Test: `numba.runtests` for Numba, `python -m llvmlite.tests` for
  llvmlite (all via `conda run`, as above).
  1. Run targeted tests for the changed areas first, e.g.
     `python -m numba.runtests numba.tests.test_foo -m <cores>`
  2. Then broader affected modules if the targeted tests pass.
  3. Full suite only when warranted; record what was actually run.
- Minimum acceptable evidence: clean build plus targeted tests passing.
- Use `@jit` (not `@njit` or `@jit(nopython=True)`) in example code,
  reproducers and source modifications.

## Output

Write the final review to
`~/reviews/pr-review-PROJECT-PR/pr-review-PROJECT-PR.md`.

Mandatory preamble:

    Reviewer: <your name/model identifier>
    Date: <YYYY-MM-DD>
    URL: https://github.com/numba/PROJECT/pull/PR
    Author: <pr author>
    Branch: <author>/<fork>:<branch> -> main
    Base: main @ <merge-base sha>
    Head: <head sha>
    State at review time: <open/closed>, <mergeable state>, CI: <pass/fail summary>
    Verdict: <approve | comment | request-changes> — <one-line justification>

Body sections, in order:

1. **Summary** — what the PR does, in a few sentences.
2. **Findings** — ordered by severity (blocker / major / minor / nit),
   each with `path/to/file.py:line` plus a reproducer or reasoning. State
   explicitly if there are no findings.
3. **Test evidence** — exact commands run and their outcomes.
4. **Limitations** — what was not verified (e.g. full test suite, other
   platforms).

## Definition of done

- [ ] Review directory, branch, worktree and conda env all named `pr-review-PROJECT-PR`
- [ ] PR head checked out in the worktree; base/head SHAs recorded
- [ ] Build succeeded in the review environment
- [ ] Targeted tests run; results recorded
- [ ] Existing human reviews checked for overlap
- [ ] `pr-review-PROJECT-PR.md` written with complete preamble and verdict
- [ ] Nothing removed; all artifacts left in `~/reviews/`

## Policy

LLM-generated reviews fall under the Numba AI tools policy:
https://numba.readthedocs.io/en/stable/reference/ai_tools_policy.html
Apply its attribution mechanism to anything posted to numba/numba or
numba/llvmlite.
